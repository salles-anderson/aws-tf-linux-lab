# =============================================================================
# Data Source - Latest Amazon Linux 2023 AMI
# =============================================================================

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# Bastion Host
# =============================================================================

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name               = var.key_name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Update system
    yum update -y

    # Install SSM Agent (usually pre-installed on Amazon Linux 2023)
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Install useful tools for bastion
    yum install -y vim htop tmux

    # Create banner
    cat > /etc/motd << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    BASTION HOST - LINUX LAB                    ║
    ║                                                                 ║
    ║  Access to Lab instances via SSH:                              ║
    ║  ssh -i /path/to/key ubuntu@<private-ip>                       ║
    ║                                                                 ║
    ║  Or use SSM Session Manager directly to Lab instances          ║
    ╚═══════════════════════════════════════════════════════════════╝
    BANNER

    echo "Bastion setup completed"
  EOF
  )

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion"
    Role = "Bastion"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}
