# healer.tf
# The heal loop's IAM role. Built code-first, no import.

# Piece 1a: who may wear the badge (trust)
data "aws_iam_policy_document" "healer_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Piece 1b: what the badge permits (all three actions, one auditable document)
data "aws_iam_policy_document" "healer_permissions" {
  statement {
    sid       = "DescribeAllInstances"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid       = "StopTaggedInstancesOnly"
    actions   = ["ec2:StopInstances"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/AutoStop"
      values   = ["true"]
    }
  }

  statement {
    sid       = "ReadCPUMetrics"
    actions   = ["cloudwatch:GetMetricStatistics"]
    resources = ["*"]
  }

  statement {
    sid = "WriteLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:us-east-1:339494983682:*"]
  }
}

# Piece 2: the badge itself
resource "aws_iam_role" "healer" {
  name               = "healer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.healer_trust.json
}

# Piece 3: the wire connecting permissions to the badge
resource "aws_iam_role_policy" "healer" {
  name   = "healer-permissions"
  role   = aws_iam_role.healer.id
  policy = data.aws_iam_policy_document.healer_permissions.json
}

# Piece 4: package the source into a zip (packaging step, runs locally at plan)
data "archive_file" "healer_zip" {
  type        = "zip"
  source_dir  = "../../../lambda/auto-stop"
  output_path = "${path.module}/auto-stop.zip"
}

# Piece 5: the function itself (the machine that wears the badge)
resource "aws_lambda_function" "healer" {
  function_name    = "auto_stop_idle_instances"
  role             = aws_iam_role.healer.arn
  runtime          = "python3.13"
  handler          = "auto_stop_idle_instances.lambda_handler"
  timeout          = 60
  filename         = data.archive_file.healer_zip.output_path
  source_code_hash = data.archive_file.healer_zip.output_base64sha256
}

# Piece 6: the clock (the schedule, ticks every hour, does nothing alone)
resource "aws_cloudwatch_event_rule" "healer_schedule" {
  name                = "hourly-idle-check"
  description         = "Fires the healer once per hour to stop idle tagged instances"
  schedule_expression = "rate(1 hour)"
}

# Piece 7: the wire (connects the clock to the healer function)
resource "aws_cloudwatch_event_target" "healer_target" {
  rule = aws_cloudwatch_event_rule.healer_schedule.name
  arn  = aws_lambda_function.healer.arn
}

# Piece 8: the doorkey (lets EventBridge invoke the healer, inbound permission)
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.healer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.healer_schedule.arn
}
