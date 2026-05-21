output "fqdn" {
  description = "委譲 NS レコードの FQDN"
  value       = aws_route53_record.this.fqdn
}
