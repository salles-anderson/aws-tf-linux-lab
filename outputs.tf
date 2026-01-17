# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

# Bastion Outputs
output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_ssm_command" {
  description = "Command to connect to Bastion via SSM"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id}"
}

# ASG Outputs
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.lab.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.lab.id
}

# SSM Commands
output "ssm_connect_instructions" {
  description = "Instructions to connect to instances"
  value       = <<-EOT

    Connect to Bastion:
    aws ssm start-session --target ${aws_instance.bastion.id}

    Connect to Lab instances:
    1. First, list running instances:
       aws ec2 describe-instances --filters "Name=tag:Name,Values=${var.project_name}-lab-instance" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress]' --output table

    2. Then connect via SSM:
       aws ssm start-session --target <instance-id>

    Or SSH through Bastion:
       ssh -J ec2-user@${aws_instance.bastion.public_ip} ubuntu@<private-ip>
  EOT
}
