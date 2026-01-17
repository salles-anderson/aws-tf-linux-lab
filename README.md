# AWS Terraform EC2

Infrastructure as Code for provisioning EC2 instances on AWS with VPC, subnets, and security groups using Terraform.

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                  VPC (10.0.0.0/16)                     │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │           Public Subnet (10.0.1.0/24)            │ │ │
│  │  │                                                  │ │ │
│  │  │  ┌────────────────────────────────────────────┐ │ │ │
│  │  │  │              EC2 Instance                  │ │ │ │
│  │  │  │                                            │ │ │ │
│  │  │  │  - Ubuntu AMI                              │ │ │ │
│  │  │  │  - SSH Access (Port 22)                    │ │ │ │
│  │  │  │  - Security Group Attached                 │ │ │ │
│  │  │  │                                            │ │ │ │
│  │  │  └────────────────────────────────────────────┘ │ │ │
│  │  │                                                  │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                          │                            │ │
│  │                          ▼                            │ │
│  │                 ┌─────────────────┐                   │ │
│  │                 │ Internet Gateway │                  │ │
│  │                 └─────────────────┘                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                          │                                  │
│                          ▼                                  │
│                      Internet                               │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource | Description |
|----------|-------------|
| VPC | Virtual Private Cloud (10.0.0.0/16) |
| Subnet | Public subnet (10.0.1.0/24) |
| Internet Gateway | Internet access for public subnet |
| Security Group | Firewall rules (SSH ingress) |
| EC2 Instance | Ubuntu-based compute instance |

## Prerequisites

- AWS Account
- Terraform >= 1.0
- AWS CLI configured
- SSH key pair created in AWS

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/salles-anderson/aws-terraform-ec2.git
cd aws-terraform-ec2
```

### 2. Configure variables

Create a `terraform.tfvars` file:

```hcl
instance_type = "t3.micro"
key_name      = "your-key-pair-name"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 4. Connect to EC2

```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

## Project Structure

```
.
├── main.tf              # Main resources (VPC, Subnet, EC2, SG)
├── variables.tf         # Input variables
├── provider.tf          # AWS provider configuration
├── outputs.tf           # Output values (if exists)
└── .github/
    └── workflows/
        └── terraform.yml  # CI/CD pipeline
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `instance_type` | EC2 instance type | t3.micro |
| `key_name` | AWS key pair name | - |
| `region` | AWS region | us-east-1 |

## CI/CD Pipeline

GitHub Actions workflow included for automated deployments.

### Required Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |

### Pipeline Features

- Terraform format check
- Terraform validation
- Plan on pull requests
- Apply on merge to main

## Security Considerations

- SSH access is open to all IPs (0.0.0.0/0) - restrict in production
- Use SSM Session Manager instead of SSH for better security
- Enable VPC Flow Logs for network monitoring
- Use IAM roles instead of access keys when possible

## Reusable Modules

For production environments, consider using the reusable Terraform modules library:

**[modules-aws-tf](https://github.com/salles-anderson/modules-aws-tf)** - 47+ production-ready AWS modules

### Example with VPC Module

```hcl
module "vpc" {
  source = "git::https://github.com/salles-anderson/modules-aws-tf.git//modules/networking/vpc?ref=main"

  project_name       = "my-project"
  vpc_cidr           = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}
```

### Example with EC2 Module

```hcl
module "ec2" {
  source = "git::https://github.com/salles-anderson/modules-aws-tf.git//modules/compute/ec2-instance?ref=main"

  name          = "my-instance"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
}
```

### Available Module Categories

| Category | Modules |
|----------|---------|
| Networking | VPC, ALB, NLB, Route53, CloudFront |
| Compute | EC2, ECS, ECR, Kong Gateway |
| Database | RDS, Aurora, DynamoDB, DocumentDB, ElastiCache |
| Security | ACM, WAF, KMS, Secrets Manager, Security Groups |
| Serverless | Lambda, SQS, Amplify, EventBridge |
| Observability | CloudWatch Alarms, Dashboards, Log Groups |
| Cost Optimization | EC2/RDS/DocumentDB Schedulers |

## Extending the Infrastructure

### Add more subnets

```hcl
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags       = { Name = "PrivateSubnet" }
}
```

### Add Application Load Balancer

```hcl
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.main.id]
}
```

### Add RDS Database

```hcl
resource "aws_db_instance" "main" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  # ... more configuration
}
```

## Outputs

After applying:

```bash
terraform output
```

Returns:
- EC2 public IP
- VPC ID
- Subnet ID

## Cleanup

```bash
terraform destroy
```

## Author

**Anderson Sales** - DevOps Cloud Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/salesanderson)
