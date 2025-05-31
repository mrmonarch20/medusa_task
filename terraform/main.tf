provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets
}

module "security" {
  source = "./modules/security"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.vpc_cidr
}

module "ecr" {
  source = "./modules/ecr"

  environment     = var.environment
  repository_names = [
    "medusa-server",
    "medusa-storefront"
  ]
}

module "database" {
  source = "./modules/database"

  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.database_subnet_ids
  db_security_group_id    = module.security.db_security_group_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = var.db_instance_class
}

module "ecs" {
  source = "./modules/ecs"

  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_subnet_ids      = module.vpc.private_subnet_ids
  app_security_group_id   = module.security.app_security_group_id
  lb_security_group_id    = module.security.lb_security_group_id
  ecs_task_execution_role = module.security.ecs_task_execution_role
  ecs_task_role           = module.security.ecs_task_role
  
  ecr_repository_server_url     = module.ecr.repository_urls["medusa-server"]
  ecr_repository_storefront_url = module.ecr.repository_urls["medusa-storefront"]
  
  db_host                 = module.database.db_instance_address
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password.db_password.result
  
  medusa_server_image     = var.medusa_server_image
  medusa_storefront_image = var.medusa_storefront_image
  
  redis_node_type         = var.redis_node_type
  ecs_task_cpu            = var.ecs_task_cpu
  ecs_task_memory         = var.ecs_task_memory
}
