output "role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "GitHub Actions IAM Role 名"
  value       = aws_iam_role.github_actions.name
}

output "ecr_push_policy_arn" {
  description = "ECR Push ポリシー ARN"
  value       = aws_iam_policy.ecr_push.arn
}

output "oidc_provider_arn" {
  description = "GitHub Actions OIDC Provider ARN"
  value       = local.oidc_provider_arn
}
