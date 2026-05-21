# ----------------------------------------
# GitHub Actions OIDC Provider
# ----------------------------------------
resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

# 呼び出し元ごとのロジック重複を避けるため、module入力だけで決まる派生値は module 内で解決する
locals {
  oidc_provider_arn        = var.create_oidc_provider ? aws_iam_openid_connect_provider.github_actions[0].arn : var.oidc_provider_arn
  tfstate_read_policy_name = var.tfstate_read_policy_name != "" ? var.tfstate_read_policy_name : "${var.role_name}-tfstate-read"
  ecs_deploy_policy_name   = var.ecs_deploy_policy_name != "" ? var.ecs_deploy_policy_name : "${var.role_name}-ecs-deploy"
}

# ----------------------------------------
# IAM Role - GitHub Actions 用
# ----------------------------------------
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.trusted_repo_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
  tags               = var.tags
}

# ----------------------------------------
# ECR Push Policy
# ----------------------------------------
data "aws_iam_policy_document" "ecr_push" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]
    resources = var.ecr_repository_arns
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_push" {
  name   = var.ecr_push_policy_name
  policy = data.aws_iam_policy_document.ecr_push.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_push.arn
}

# ----------------------------------------
# tfstate Read Policy (optional)
# ----------------------------------------
data "aws_iam_policy_document" "tfstate_read" {
  count = length(var.tfstate_read_object_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = var.tfstate_read_object_arns
  }
}

resource "aws_iam_policy" "tfstate_read" {
  count  = length(var.tfstate_read_object_arns) > 0 ? 1 : 0
  name   = local.tfstate_read_policy_name
  policy = data.aws_iam_policy_document.tfstate_read[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "tfstate_read" {
  count      = length(var.tfstate_read_object_arns) > 0 ? 1 : 0
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.tfstate_read[0].arn
}

# ----------------------------------------
# ECS Deploy Policy (optional)
# ----------------------------------------
data "aws_iam_policy_document" "ecs_deploy" {
  count = var.ecs_deploy_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:DescribeServices",
      "ecs:ListServiceDeployments",
      "ecs:DescribeServiceDeployments",
      "ecs:DescribeTaskSets",
      "ecs:UpdateService",
    ]
    resources = var.ecs_deploy_resource_arns
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServiceDeployments",
    ]
    resources = var.ecs_service_deployment_resource_arns
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
    ]
    resources = var.ecs_cluster_resource_arns
  }

  statement {
    effect = "Allow"
    # DescribeTaskDefinition は実行時に resource=* で評価されるケースがあるため、ここは * を許可する
    actions = [
      "ecs:DescribeTaskDefinition",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    # ListTaskDefinitions は resource-level 制御できないため * を許可する
    actions = [
      "ecs:ListTaskDefinitions",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.ecs_pass_role_arns) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "iam:PassRole",
      ]
      resources = var.ecs_pass_role_arns

      condition {
        test     = "StringEquals"
        variable = "iam:PassedToService"
        values   = ["ecs-tasks.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_policy" "ecs_deploy" {
  count  = var.ecs_deploy_enabled ? 1 : 0
  name   = local.ecs_deploy_policy_name
  policy = data.aws_iam_policy_document.ecs_deploy[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_deploy" {
  count      = var.ecs_deploy_enabled ? 1 : 0
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecs_deploy[0].arn
}
