# CloudFront ディストリビューション (CSR フロントエンド用)
# Origin: S3 (OAC 経由)
# engineering-dev はデフォルトドメイン (d*.cloudfront.net) を使用

# Origin Access Control (OAC) for S3
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.oac_name
  description                       = "OAC for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = var.comment
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.web_acl_arn

  # S3 Origin (CSR 静的ファイル)
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  # デフォルトキャッシュビヘイビア (S3 → 静的ファイル)
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    # CachingOptimized マネージドポリシー
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    compress = true
  }

  # SPA 用: 404 → index.html にフォールバック (CSR ルーティング対応)
  # 403 は WAF ブロック時にも返るため、フォールバック対象にしない
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ACM 証明書未指定時は CloudFront 組み込み証明書を使用
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? var.ssl_support_method : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? var.minimum_protocol_version : null
  }

  # 標準ログ (アクセスログ)
  dynamic "logging_config" {
    for_each = var.logging_bucket_domain_name != "" ? [1] : []
    content {
      bucket          = var.logging_bucket_domain_name
      prefix          = var.logging_prefix
      include_cookies = false
    }
  }

  tags = var.tags
}

# S3 バケットポリシー: CloudFront OAC からのアクセスのみ許可
# 循環依存回避のため CloudFront モジュール側で作成
resource "aws_s3_bucket_policy" "origin" {
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}
