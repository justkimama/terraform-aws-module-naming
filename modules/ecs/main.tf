# ----------------------------------------
# ECS Cluster
# ----------------------------------------
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, { Name = var.cluster_name })
}

# ----------------------------------------
# CloudWatch Log Group
# ecspresso の taskdef.json で logConfiguration.options.awslogs-group に指定する
# ----------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ----------------------------------------
# IAM - Task Execution Role
# ECS エージェントが使用: ECR pull / CloudWatch Logs 書き込み / Secrets Manager 参照
# ----------------------------------------
resource "aws_iam_role" "task_execution" {
  name = var.task_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = var.task_execution_role_name })
}

resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets Manager からシークレットを取得するポリシー (RDS パスワード等)
# secrets_arns が空の場合はポリシーを作成しない
resource "aws_iam_policy" "task_execution_secrets" {
  count = length(var.secrets_arns) > 0 ? 1 : 0

  name = var.exec_secrets_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.secrets_arns
    }]
  })

  tags = merge(var.tags, { Name = var.exec_secrets_policy_name })
}

resource "aws_iam_role_policy_attachment" "task_execution_secrets" {
  count = length(var.secrets_arns) > 0 ? 1 : 0

  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.task_execution_secrets[0].arn
}

# ----------------------------------------
# IAM - Task Role
# コンテナ自身が使用: アプリから AWS サービスへのアクセス権
# 必要に応じて env 側でポリシーを追加アタッチする
# ----------------------------------------
resource "aws_iam_role" "task" {
  name = var.task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = var.task_role_name })
}
