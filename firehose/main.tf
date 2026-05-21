# ----------------------------------------
# IAM - Firehose → S3
# ----------------------------------------
resource "aws_iam_role" "firehose" {
  name = var.firehose_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = var.firehose_role_name })
}

resource "aws_iam_policy" "firehose_s3" {
  name = "${var.firehose_role_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*",
        ]
      },
    ]
  })

  tags = merge(var.tags, { Name = "${var.firehose_role_name}-policy" })
}

resource "aws_iam_role_policy_attachment" "firehose_s3" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose_s3.arn
}

# ----------------------------------------
# IAM - CloudWatch Logs → Firehose
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cwlogs" {
  name = var.cwlogs_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "logs.${data.aws_region.current.name}.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringLike = {
          "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        }
      }
    }]
  })

  tags = merge(var.tags, { Name = var.cwlogs_role_name })
}

resource "aws_iam_policy" "cwlogs_firehose" {
  name = "${var.cwlogs_role_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"]
      Resource = aws_kinesis_firehose_delivery_stream.this.arn
    }]
  })

  tags = merge(var.tags, { Name = "${var.cwlogs_role_name}-policy" })
}

resource "aws_iam_role_policy_attachment" "cwlogs_firehose" {
  role       = aws_iam_role.cwlogs.name
  policy_arn = aws_iam_policy.cwlogs_firehose.arn
}

# ----------------------------------------
# Firehose Delivery Stream
# Dynamic Partitioning でロググループ名をプレフィックスに使用
# CWL → Firehose のデータは Base64 + gzip 圧縮されるため
# lambda_processor で decompress が必要 → processor type = RecordDeAggregation は不可
# CloudWatch Logs のサブスクリプション配信は JSON の logEvents 配列を含む構造なので
# Dynamic Partitioning の jq クエリで logGroup を抽出する
# ----------------------------------------
resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = var.s3_bucket_arn

    # Dynamic Partitioning プレフィックス
    # CWL から届くペイロードの logGroup フィールドを使用
    # 例: /ecs/pj-dev/control-nginx → prefix = ecs/control-nginx/!{partitionKeyFromQuery:log_group}/...
    # logGroup の先頭 "/" を除いてそのままプレフィックスに使う
    prefix              = "${var.s3_prefix}/!{partitionKeyFromQuery:log_group}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{timestamp:HH}/"
    error_output_prefix = "${var.s3_prefix}/errors/!{firehose:error-output-type}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"

    buffering_interval = var.buffer_interval_seconds
    buffering_size     = var.buffer_size_mb

    compression_format = "GZIP"

    dynamic_partitioning_configuration {
      enabled        = true
      retry_duration = 300
    }

    processing_configuration {
      enabled = true

      # CloudWatch Logs サブスクリプション配信データは Base64+gzip なので展開する
      processors {
        type = "Decompression"
        parameters {
          parameter_name  = "CompressionFormat"
          parameter_value = "GZIP"
        }
      }

      # 展開後の JSON から logGroup を抽出して Dynamic Partitioning キーに使う
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{log_group: .logGroup | ltrimstr(\"/\")}"
        }
      }

      # logEvents 配列を1行ずつ展開して S3 に書き込む (1レコード = 1ログイベント)
      processors {
        type = "AppendDelimiterToRecord"
      }
    }
  }

  tags = merge(var.tags, { Name = var.stream_name })
}

# ----------------------------------------
# CloudWatch Logs Subscription Filters
# ----------------------------------------
resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = toset(var.log_group_names)

  name            = "${var.stream_name}-${replace(each.value, "/", "-")}"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.this.arn
  role_arn        = aws_iam_role.cwlogs.arn

  distribution = "ByLogStream"
}
