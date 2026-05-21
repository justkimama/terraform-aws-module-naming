resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  # PublicサブネットのみパブリックIP自動割り当てを有効化
  map_public_ip_on_launch = each.value.tier == "public" ? true : false

  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}" })
}
