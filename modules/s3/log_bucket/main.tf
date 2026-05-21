resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-logs"
    status = "Enabled"
    filter {}

    expiration {
      days = var.retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "alb_access_logs" {
  count = var.log_type == "alb" ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.elb_account_id}:root" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "vpc_flow_logs" {
  count = var.log_type == "vpc_flow" ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.this.arn
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_standard" {
  count = var.log_type == "cloudfront_standard" ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_standard" {
  count = var.log_type == "cloudfront_standard" ? 1 : 0

  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_standard]
  bucket     = aws_s3_bucket.this.id
  acl        = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.replication_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  count = var.replication_enabled ? 1 : 0

  name_prefix = "s3-repl-${var.log_type}-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.this.arn
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "replication" {
  count = var.replication_enabled ? 1 : 0

  name_prefix = "s3-repl-${var.log_type}-"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.this.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ]
        Resource = [
          "${aws_s3_bucket.this.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = [
          "${var.replication_destination_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.replication_enabled ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.replication_enabled ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "replicate-to-audit"
    status = "Enabled"

    delete_marker_replication {
      status = "Disabled"
    }

    filter {}

    destination {
      bucket        = var.replication_destination_bucket_arn
      account       = var.replication_destination_account_id
      storage_class = var.replication_destination_storage_class

      access_control_translation {
        owner = "Destination"
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this,
    aws_iam_role_policy_attachment.replication
  ]
}
