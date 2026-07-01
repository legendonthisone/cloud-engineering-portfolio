# GitHub Actions OIDC Role for Terraform
# This role is assumed by GitHub Actions when running terraform plan/apply
# Trust policy: Only GitHub (via OIDC) can assume this role
# Identity policy: Only the specific permissions Terraform needs

# Trust Policy: Who can assume this role?
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:legendonthisone/cloud-engineering-portfolio:*"]
    }

    # Audience check: confirms the OIDC token was minted for AWS STS,
    # not for some other service. This existed on the live role and must
    # stay - it is a real security control.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Identity Policy: What can this role do?
data "aws_iam_policy_document" "github_actions_permissions" {

  # EC2 READ: Describe calls are how terraform plan reads infrastructure.
  # NO region condition - reads cannot change anything, and conditioning
  # Describe* can break plan. Reads open, writes locked.
  statement {
    sid    = "TerraformEC2Read"
    effect = "Allow"
    actions = [
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  # EC2 WRITE: All mutating calls (create/delete/modify/run/terminate).
  # Region-locked to us-east-1 so leaked credentials cannot spin up or
  # destroy resources in other regions (classic abuse pattern).
  statement {
    sid    = "TerraformEC2Write"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  # S3: Read and write Terraform state (restricted to state bucket only)
  statement {
    sid    = "TerraformStateBackend"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::legend-tf-state-2026"]
  }

  statement {
    sid    = "TerraformStateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::legend-tf-state-2026/*"]
  }
}

# Create the role
resource "aws_iam_role" "github_actions_terraform" {
  name               = "github-actions-terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  description = "Role for GitHub Actions to run Terraform on AWS infrastructure"
}

# Attach the permissions policy to the role
resource "aws_iam_role_policy" "github_actions_terraform" {
  name   = "terraform-infra-policy"
  role   = aws_iam_role.github_actions_terraform.id
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

# Data source: Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Output the role ARN (useful for debugging)
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_terraform.arn
  description = "ARN of the GitHub Actions Terraform role"
}
