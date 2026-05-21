data "aws_region" "current" {}

data "aws_route53_zone" "selected" {
  count   = var.enable_route53_zone_lookup ? 1 : 0
  zone_id = var.route53_zone_id
}

locals {
  is_domain_identity = length(regexall("@", var.email_identity)) == 0
  has_route53_zone   = var.enable_route53_zone_lookup
  route53_zone_name  = local.has_route53_zone ? trimsuffix(data.aws_route53_zone.selected[0].name, ".") : null

  identity_records_zone_matches = local.has_route53_zone && local.is_domain_identity && local.route53_zone_name == var.email_identity
  can_create_identity_records   = local.identity_records_zone_matches

  mail_from_domain_defaults = var.custom_mail_from_domain == null ? {} : {
    (var.custom_mail_from_domain) = {
      mx_region   = var.mail_from_mx_region
      spf_value   = var.mail_from_spf_value
      dmarc_value = var.dmarc_txt_value
    }
  }

  merged_mail_from_domains = merge(local.mail_from_domain_defaults, var.additional_mail_from_domains)

  resolved_mail_from_domains = {
    for domain, config in local.merged_mail_from_domains :
    domain => {
      mx_region   = coalesce(try(config.mx_region, null), data.aws_region.current.name)
      spf_value   = coalesce(try(config.spf_value, null), var.mail_from_spf_value)
      dmarc_value = coalesce(try(config.dmarc_value, null), var.dmarc_txt_value)
    }
  }

  in_zone_mail_from_domains = local.has_route53_zone ? {
    for domain, config in local.resolved_mail_from_domains :
    domain => config
    if endswith(domain, local.route53_zone_name)
  } : {}

  out_of_zone_mail_from_domains = local.has_route53_zone ? [
    for domain in keys(local.resolved_mail_from_domains) :
    domain
    if !endswith(domain, local.route53_zone_name)
  ] : []
}

resource "aws_sesv2_email_identity" "this" {
  email_identity         = var.email_identity
  configuration_set_name = var.configuration_set_name

  dynamic "dkim_signing_attributes" {
    for_each = var.manage_dkim_signing_attributes ? [1] : []
    content {
      next_signing_key_length = var.next_signing_key_length
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = (
        !var.create_dkim_cname_records ||
        !local.has_route53_zone ||
        local.identity_records_zone_matches
      )
      error_message = "Domain identity の DKIM レコードを作成する場合、route53_zone_id は email_identity と同一ドメインのホストゾーンを指定してください。"
    }

    precondition {
      condition = (
        !var.create_mail_from_records ||
        !local.has_route53_zone ||
        length(local.out_of_zone_mail_from_domains) == 0
      )
      error_message = "MAIL FROM 用 DNS レコードを作成する場合、additional_mail_from_domains/custom_mail_from_domain はすべて route53_zone_id 配下のドメインにしてください。"
    }

    precondition {
      condition = (
        !var.create_dmarc_txt_records ||
        !local.has_route53_zone ||
        length(local.out_of_zone_mail_from_domains) == 0
      )
      error_message = "DMARC TXT レコードを作成する場合、additional_mail_from_domains/custom_mail_from_domain はすべて route53_zone_id 配下のドメインにしてください。"
    }
  }
}

resource "aws_sesv2_email_identity_feedback_attributes" "this" {
  count = var.feedback_forwarding_enabled == null ? 0 : 1

  email_identity           = aws_sesv2_email_identity.this.email_identity
  email_forwarding_enabled = var.feedback_forwarding_enabled
}

resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  count = var.custom_mail_from_domain == null ? 0 : 1

  email_identity         = aws_sesv2_email_identity.this.email_identity
  mail_from_domain       = var.custom_mail_from_domain
  behavior_on_mx_failure = var.mail_from_behavior_on_mx_failure

  lifecycle {
    precondition {
      condition = (
        !var.create_mail_from_records ||
        !local.has_route53_zone ||
        var.custom_mail_from_domain == null ||
        contains(keys(local.in_zone_mail_from_domains), var.custom_mail_from_domain)
      )
      error_message = "MAIL FROM 用 DNS レコードを作成する場合、custom_mail_from_domain が route53_zone_id のホストゾーン配下である必要があります。"
    }
  }
}

resource "aws_route53_record" "dkim_cname" {
  count = local.can_create_identity_records && var.create_dkim_cname_records ? 3 : 0

  zone_id = var.route53_zone_id
  name    = "${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.email_identity}"
  type    = "CNAME"
  ttl     = var.route53_record_ttl
  records = ["${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mail_from_mx" {
  for_each = var.create_mail_from_records ? local.in_zone_mail_from_domains : {}

  zone_id = var.route53_zone_id
  name    = each.key
  type    = "MX"
  ttl     = var.route53_record_ttl
  records = ["10 feedback-smtp.${each.value.mx_region}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_txt" {
  for_each = var.create_mail_from_records ? local.in_zone_mail_from_domains : {}

  zone_id = var.route53_zone_id
  name    = each.key
  type    = "TXT"
  ttl     = var.route53_record_ttl
  records = [each.value.spf_value]
}

resource "aws_route53_record" "mail_from_dmarc_txt" {
  for_each = var.create_dmarc_txt_records ? local.in_zone_mail_from_domains : {}

  zone_id = var.route53_zone_id
  name    = "_dmarc.${each.key}"
  type    = "TXT"
  ttl     = var.route53_record_ttl
  records = [each.value.dmarc_value]
}
