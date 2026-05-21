output "alias_a_fqdns" {
  description = "作成した Alias A レコード FQDN のマップ"
  value       = { for k, v in aws_route53_record.alias_a : k => v.fqdn }
}

output "cname_fqdns" {
  description = "作成した CNAME レコード FQDN のマップ"
  value       = { for k, v in aws_route53_record.cname : k => v.fqdn }
}
