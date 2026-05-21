output "cluster_name" {
  description = "ECS Cluster名 (ecspresso の service.json で指定する)"
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "task_execution_role_arn" {
  description = "Task Execution Role ARN (ecspresso の taskdef.json で指定する)"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "Task Role ARN (ecspresso の taskdef.json で指定する)"
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "CloudWatch Log Group名 (ecspresso の taskdef.json logConfiguration で指定する)"
  value       = aws_cloudwatch_log_group.this.name
}
