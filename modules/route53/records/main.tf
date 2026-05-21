resource "aws_route53_record" "alias_a" {
  for_each = var.alias_a_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.target_dns_name
    zone_id                = each.value.target_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

resource "aws_route53_record" "cname" {
  for_each = var.cname_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = each.value.ttl
  records = each.value.records
}
