resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = var.comment

  vpc {
    vpc_id = var.vpc_id
  }

  tags = var.tags
}
