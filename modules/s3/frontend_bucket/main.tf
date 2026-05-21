# S3 バケット (CSR フロントエンド静的ホスティング用)
# CloudFront OAC 経由のみアクセスを許可する
# バケットポリシーは CloudFront モジュール側で設定 (循環依存回避)

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}

# パブリックアクセスを完全にブロック (OAC 経由のみ)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# サーバーサイド暗号化 (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
