output "arn" {
  description = "SES identity ARN"
  value       = aws_sesv2_email_identity.this.arn
}

output "email_identity" {
  description = "SES identity 名"
  value       = aws_sesv2_email_identity.this.email_identity
}

output "identity_type" {
  description = "SES identity 種別"
  value       = aws_sesv2_email_identity.this.identity_type
}

output "verified_for_sending_status" {
  description = "SES identity の送信利用可否"
  value       = aws_sesv2_email_identity.this.verified_for_sending_status
}

output "dkim_signing_status" {
  description = "SES DKIM ステータス"
  value       = try(aws_sesv2_email_identity.this.dkim_signing_attributes[0].status, null)
}

output "feedback_forwarding_enabled" {
  description = "feedback forwarding 設定値"
  value       = try(aws_sesv2_email_identity_feedback_attributes.this[0].email_forwarding_enabled, null)
}

output "mail_from_domain" {
  description = "MAIL FROM ドメイン"
  value       = try(aws_sesv2_email_identity_mail_from_attributes.this[0].mail_from_domain, null)
}

output "dkim_cname_record_fqdns" {
  description = "DKIM CNAME レコード FQDN 一覧"
  value       = aws_route53_record.dkim_cname[*].fqdn
}

output "mail_from_mx_record_fqdn" {
  description = "MAIL FROM MX レコード FQDN (互換性のため先頭 1 件)"
  value       = length(aws_route53_record.mail_from_mx) > 0 ? aws_route53_record.mail_from_mx[sort(keys(aws_route53_record.mail_from_mx))[0]].fqdn : null
}

output "mail_from_mx_record_fqdns" {
  description = "MAIL FROM MX レコード FQDN マップ"
  value       = { for domain, record in aws_route53_record.mail_from_mx : domain => record.fqdn }
}

output "mail_from_dmarc_record_fqdns" {
  description = "MAIL FROM DMARC TXT レコード FQDN マップ"
  value       = { for domain, record in aws_route53_record.mail_from_dmarc_txt : domain => record.fqdn }
}

output "required_easy_dkim_cname_records" {
  description = "手動登録用 Easy DKIM CNAME レコード定義"
  value = local.is_domain_identity ? [
    for token in try(aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens, []) : {
      name  = "${token}._domainkey.${var.email_identity}"
      type  = "CNAME"
      value = "${token}.dkim.amazonses.com"
    }
  ] : []
}

output "required_mail_from_dns_records" {
  description = "手動登録用 MAIL FROM/DMARC レコード定義"
  value = {
    for domain, config in local.resolved_mail_from_domains :
    domain => {
      mx = {
        name  = domain
        type  = "MX"
        value = "10 feedback-smtp.${config.mx_region}.amazonses.com"
      }
      spf = {
        name  = domain
        type  = "TXT"
        value = config.spf_value
      }
      dmarc = {
        name  = "_dmarc.${domain}"
        type  = "TXT"
        value = config.dmarc_value
      }
    }
  }
}
