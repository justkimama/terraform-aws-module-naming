output "delivery_stream_arn" {
  description = "Firehose Delivery Stream の ARN"
  value       = aws_kinesis_firehose_delivery_stream.this.arn
}

output "delivery_stream_name" {
  description = "Firehose Delivery Stream 名"
  value       = aws_kinesis_firehose_delivery_stream.this.name
}

output "firehose_role_arn" {
  description = "Firehose → S3 IAM ロールの ARN"
  value       = aws_iam_role.firehose.arn
}

output "cwlogs_role_arn" {
  description = "CloudWatch Logs → Firehose IAM ロールの ARN"
  value       = aws_iam_role.cwlogs.arn
}
