resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = var.comment
  tags    = var.tags
}
