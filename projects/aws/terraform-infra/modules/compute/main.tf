data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-USERDATA
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Deployed by Terraform via a modular, multi-AZ pipeline -Legend</h1>" > /usr/share/nginx/html/index.html
  USERDATA

  tags = {
    Name    = "${var.project_name}-${var.environment}-web-server"
    Project = var.project_name
    Env     = var.environment
  }
}
