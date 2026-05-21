output "policy_arn" {
  description = "作成した IAM Policy ARN"
  value       = try(aws_iam_policy.this[0].arn, null)
}

output "policy_name" {
  description = "作成した IAM Policy 名"
  value       = try(aws_iam_policy.this[0].name, null)
}
