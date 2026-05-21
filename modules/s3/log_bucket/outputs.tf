output "bucket_id" {
  description = "S3 バケット ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 バケット ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "S3 バケット名"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
  description = "S3 バケットのドメイン名"
  value       = aws_s3_bucket.this.bucket_domain_name
}
