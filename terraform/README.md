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

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Create a `terraform.tfvars` file with your variables:
   ```
   aws_region = "us-east-1"
   environment = "dev"
   db_password = "your-secure-password"
   ```

3. Plan the deployment:
   ```
   terraform plan -out=tfplan
   ```

4. Apply the changes:
   ```
   terraform apply tfplan
   ```

5. Build and push Docker images:
   ```
   # Get ECR repository URLs
   export SERVER_REPO=$(terraform output -raw ecr_repository_urls | jq -r '."medusa-server"')
   export STOREFRONT_REPO=$(terraform output -raw ecr_repository_urls | jq -r '."medusa-storefront"')
   
   # Login to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $SERVER_REPO
   
   # Build and push server image
   docker build -t $SERVER_REPO:latest -f Dockerfile .
   docker push $SERVER_REPO:latest
   
   # Build and push storefront image
   docker build -t $STOREFRONT_REPO:latest -f Dockerfile.storefront ./my-medusa-store-storefront
   docker push $STOREFRONT_REPO:latest
   ```

6. Access the application:
   ```
   # Get the load balancer DNS name
   terraform output load_balancer_dns
   
   # Access the admin panel
   echo "http://$(terraform output -raw load_balancer_dns):9000/app"
   
   # Access the storefront
   echo "http://$(terraform output -raw load_balancer_dns):8000"
   ```

## Admin Access

After deployment, you can access the admin panel with:
- Email: raja123@gmail.com
- Password: password

## Clean Up

To destroy all resources:
```
terraform destroy
```

## Notes

- For production environments, consider enabling HTTPS with ACM certificates
- Adjust instance sizes based on your traffic requirements
- Consider implementing auto-scaling for the ECS service
- Use AWS Secrets Manager for sensitive values in production
