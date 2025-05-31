variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID of the application security group"
  type        = string
}

variable "lb_security_group_id" {
  description = "ID of the load balancer security group"
  type        = string
}

variable "ecs_task_execution_role" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecr_repository_server_url" {
  description = "URL of the ECR repository for the Medusa server"
  type        = string
}

variable "ecr_repository_storefront_url" {
  description = "URL of the ECR repository for the Medusa storefront"
  type        = string
}

variable "db_host" {
  description = "Host of the database"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "redis_endpoint" {
  description = "Endpoint of the Redis cluster"
  type        = string
}

variable "medusa_server_image" {
  description = "Docker image for Medusa server"
  type        = string
}

variable "medusa_storefront_image" {
  description = "Docker image for Medusa storefront"
  type        = string
}

variable "redis_node_type" {
  description = "Node type for ElastiCache Redis"
  type        = string
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
}
