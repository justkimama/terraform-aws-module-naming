# ----------------------------------------
# IAM Role - RDS Proxy が Secrets Manager からDB認証情報を取得するためのロール
# ----------------------------------------
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = var.role_name })
}

resource "aws_iam_policy" "secrets" {
  name = var.policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secret_arn
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetResourcePolicy", "secretsmanager:DescribeSecret", "secretsmanager:ListSecretVersionIds"]
        Resource = var.secret_arn
      }
    ]
  })

  tags = merge(var.tags, { Name = var.policy_name })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.secrets.arn
}

# ----------------------------------------
# RDS Proxy
# ----------------------------------------
resource "aws_db_proxy" "this" {
  name                   = var.name
  engine_family          = var.engine_family
  role_arn               = aws_iam_role.this.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = true

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = var.secret_arn
  }

  tags = merge(var.tags, { Name = var.name })
}

# ----------------------------------------
# Default Target Group
# ----------------------------------------
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
  }
}

# ----------------------------------------
# Target (Aurora Cluster)
# ----------------------------------------
resource "aws_db_proxy_target" "this" {
  db_proxy_name         = aws_db_proxy.this.name
  target_group_name     = aws_db_proxy_default_target_group.this.name
  db_cluster_identifier = var.cluster_identifier
}

# ----------------------------------------
# Read-Only Endpoint
# ----------------------------------------
resource "aws_db_proxy_endpoint" "read_only" {
  db_proxy_name          = aws_db_proxy.this.name
  db_proxy_endpoint_name = var.read_only_endpoint_name
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  target_role            = "READ_ONLY"

  tags = merge(var.tags, { Name = var.read_only_endpoint_name })
}
