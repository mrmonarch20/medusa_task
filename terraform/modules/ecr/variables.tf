variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}
