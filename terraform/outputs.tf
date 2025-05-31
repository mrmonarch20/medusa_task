output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnet_ids
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = module.ecr.repository_urls
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = module.database.db_instance_address
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.database.db_instance_endpoint
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ecs.load_balancer_dns
}

output "medusa_admin_url" {
  description = "URL for the Medusa admin panel"
  value       = "http://${module.ecs.load_balancer_dns}:9000/app"
}

output "medusa_storefront_url" {
  description = "URL for the Medusa storefront"
  value       = "http://${module.ecs.load_balancer_dns}:8000"
}

output "medusa_admin_credentials" {
  description = "Credentials for the Medusa admin panel"
  value       = "Email: raja123@gmail.com, Password: password"
  sensitive   = true
}
