# ACM モジュールを certificate_dns 配下に分けている理由:
# - 本モジュールの責務を「DNS 検証付き証明書発行」に限定して明確化するため
# - 将来、別方式 (例: Private CA / 外部DNS検証 / 既存証明書参照) を module/acm/private_dnsなどのフォルダを作成し、並列追加しやすくするため
resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = var.validation_record_ttl
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
