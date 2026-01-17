# =============================================================================
# Project Variables
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "linux-lab"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# VPC Variables
# =============================================================================

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# =============================================================================
# EC2 Variables
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type for lab instances"
  type        = string
  default     = "t3.micro"
}

variable "bastion_instance_type" {
  description = "Bastion instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name (optional - SSM is preferred)"
  type        = string
  default     = null
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

# =============================================================================
# Auto Scaling Variables
# =============================================================================

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

# =============================================================================
# Lab Configuration
# =============================================================================

variable "install_packages" {
  description = "List of packages to install via user-data"
  type        = list(string)
  default = [
    "htop",
    "vim",
    "curl",
    "wget",
    "git",
    "jq",
    "tree",
    "net-tools",
    "tcpdump",
    "nmap",
    "iotop",
    "sysstat",
    "unzip",
    "docker.io",
    "docker-compose"
  ]
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
