# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-medusa-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.environment}-medusa-cluster"
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.environment}-medusa"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-medusa-logs"
    Environment = var.environment
  }
}

# EFS File System for persistent storage
resource "aws_efs_file_system" "main" {
  creation_token = "${var.environment}-medusa-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "${var.environment}-medusa-efs"
    Environment = var.environment
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.app_security_group_id]
}

# EFS Access Point for PostgreSQL data
resource "aws_efs_access_point" "postgres" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/postgres"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name        = "${var.environment}-postgres-efs-ap"
    Environment = var.environment
  }
}

# EFS Access Point for Redis data
resource "aws_efs_access_point" "redis" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/redis"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name        = "${var.environment}-redis-efs-ap"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-medusa-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = {
    Name        = "${var.environment}-medusa-alb"
    Environment = var.environment
  }
}

# ALB Target Group for Medusa Server (port 9000)
resource "aws_lb_target_group" "server" {
  name        = "${var.environment}-medusa-server-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name        = "${var.environment}-medusa-server-tg"
    Environment = var.environment
  }
}

# ALB Target Group for Custom API Server (port 7000)
resource "aws_lb_target_group" "api" {
  name        = "${var.environment}-medusa-api-tg"
  port        = 7000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/store/regions"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name        = "${var.environment}-medusa-api-tg"
    Environment = var.environment
  }
}

# ALB Target Group for Storefront (port 8000)
resource "aws_lb_target_group" "storefront" {
  name        = "${var.environment}-medusa-storefront-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200,307"
  }

  tags = {
    Name        = "${var.environment}-medusa-storefront-tg"
    Environment = var.environment
  }
}

# ALB Listener for HTTP (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.storefront.arn
  }
}

# ALB Listener Rule for Medusa Server (port 9000)
resource "aws_lb_listener_rule" "server" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }

  condition {
    host_header {
      values = ["${var.environment}-medusa-server.*"]
    }
  }
}

# ALB Listener Rule for Custom API Server (port 7000)
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    host_header {
      values = ["${var.environment}-medusa-api.*"]
    }
  }
}

# Task Definition for Medusa
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-medusa"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = jsonencode([
    {
      name      = "medusa-server"
      image     = var.medusa_server_image
      essential = true
      
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        },
        {
          containerPort = 7000
          hostPort      = 7000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.db_username}:${var.db_password}@${var.db_host}:5432/${var.db_name}?sslmode=disable"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:6379"
        },
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "server"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:9000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    },
    {
      name      = "medusa-storefront"
      image     = var.medusa_storefront_image
      essential = true
      
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "NEXT_PUBLIC_MEDUSA_BACKEND_URL"
          value = "http://localhost:7000"
        },
        {
          name  = "MEDUSA_BACKEND_URL"
          value = "http://localhost:7000"
        },
        {
          name  = "NEXT_PUBLIC_BASE_URL"
          value = "http://localhost:8000"
        },
        {
          name  = "NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY"
          value = "pk_test"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "storefront"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      dependsOn = [
        {
          containerName = "medusa-server"
          condition     = "START"
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.environment}-medusa-task"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name                               = "${var.environment}-medusa-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 120
  force_new_deployment               = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.server.arn
    container_name   = "medusa-server"
    container_port   = 9000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "medusa-server"
    container_port   = 7000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.storefront.arn
    container_name   = "medusa-storefront"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "${var.environment}-medusa-service"
    Environment = var.environment
  }
}
