output "zone_id" {
  description = "作成したプライベートホストゾーン ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "作成したプライベートホストゾーン名"
  value       = aws_route53_zone.this.name
}
