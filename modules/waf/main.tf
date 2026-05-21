# WAF Web ACL
# scope = "CLOUDFRONT" → us-east-1 で作成する必要あり (provider で切替)
# scope = "REGIONAL"   → ALB と同じリージョンで作成

# 許可 IP セット (allowed_ip_addresses が指定された場合のみ作成)
resource "aws_wafv2_ip_set" "allowed" {
  count = length(var.allowed_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name}-allowed-ips"
  description        = "Allowed IP addresses"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_addresses

  tags = var.tags
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = length(var.allowed_ip_addresses) > 0 ? [] : [1]
      content {}
    }
    dynamic "block" {
      for_each = length(var.allowed_ip_addresses) > 0 ? [1] : []
      content {}
    }
  }

  # IP 制限ルール (allowed_ip_addresses が指定された場合のみ)
  dynamic "rule" {
    for_each = length(var.allowed_ip_addresses) > 0 ? [1] : []
    content {
      name     = "AllowedIPAddresses"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowed[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-allowed-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS マネージドルール: Common Rule Set (SQLi, XSS, etc.)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  # AWS マネージドルール: Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # レートリミット
  rule {
    name     = "RateLimit"
    priority = 30

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# ALB 用の WAF 関連付け (scope = "REGIONAL" の場合のみ)
resource "aws_wafv2_web_acl_association" "this" {
  count = var.enable_association ? 1 : 0

  resource_arn = var.association_resource_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# WAF ログ設定 (logging_enabled = true の場合のみ)
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.logging_enabled ? 1 : 0

  log_destination_configs = [var.logging_s3_bucket_arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}
