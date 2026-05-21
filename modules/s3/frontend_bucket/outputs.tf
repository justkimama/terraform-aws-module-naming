output "bucket_id" {
  description = "S3 バケット ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 バケット ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "S3 バケットのリージョナルドメイン名 (CloudFront Origin 用)"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
