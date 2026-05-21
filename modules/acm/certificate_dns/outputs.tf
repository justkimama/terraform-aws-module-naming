output "certificate_arn" {
  description = "発行された ACM 証明書 ARN"
  value       = aws_acm_certificate.this.arn
}

output "validation_record_fqdns" {
  description = "DNS 検証レコード FQDN 一覧"
  value       = [for record in aws_route53_record.validation : record.fqdn]
}

output "status" {
  description = "ACM 証明書ステータス"
  value       = aws_acm_certificate.this.status
}
