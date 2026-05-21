output "zone_id" {
  description = "作成したホストゾーン ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "作成したホストゾーン名"
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "作成したホストゾーンの NS 一覧"
  value       = aws_route53_zone.this.name_servers
}
