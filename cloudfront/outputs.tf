output "distribution_id" {
  description = "CloudFront ディストリビューション ID"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront ディストリビューション ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront ディストリビューションドメイン名 (d*.cloudfront.net)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront ディストリビューションの Route53 Hosted Zone ID"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
