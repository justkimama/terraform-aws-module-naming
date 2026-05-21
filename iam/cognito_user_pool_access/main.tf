data "aws_iam_policy_document" "this" {
  count = var.enabled ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = var.read_actions
    resources = [var.user_pool_arn]
  }

  statement {
    effect    = "Allow"
    actions   = var.admin_actions
    resources = [var.user_pool_arn]
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enabled ? 1 : 0
  name   = var.policy_name
  policy = data.aws_iam_policy_document.this[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.enabled ? 1 : 0
  role       = var.role_name
  policy_arn = aws_iam_policy.this[0].arn
}
