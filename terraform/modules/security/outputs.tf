output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "lb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis.id
}

output "ecs_task_execution_role" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}
