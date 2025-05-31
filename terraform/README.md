# Medusa E-commerce Terraform Infrastructure

This repository contains Terraform code to deploy a Medusa e-commerce application on AWS. The infrastructure includes:

- VPC with public, private, and database subnets
- RDS PostgreSQL database
- ElastiCache Redis cluster
- ECR repositories for Docker images
- ECS Fargate for running containers
- Application Load Balancer
- EFS for persistent storage
- Security groups and IAM roles

## Directory Structure

```
terraform/
├── main.tf              # Main configuration file
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── backend.tf           # Terraform backend configuration
├── modules/
│   ├── vpc/             # VPC and networking resources
│   ├── ecr/             # ECR repositories
│   ├── ecs/             # ECS cluster, service, and task definition
│   ├── database/        # RDS and ElastiCache resources
│   └── security/        # Security groups and IAM roles
```

## Prerequisites

1. AWS CLI installed and configured
2. Terraform v1.0.0 or newer
3. Docker installed (for building and pushing images)
4. S3 bucket and DynamoDB table for Terraform state (optional)



