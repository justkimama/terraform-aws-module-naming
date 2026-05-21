resource "aws_eip" "this" {
  for_each = var.nat_gateways

  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-${each.key}-eip" })
}

resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateways

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = each.value

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-${each.key}" })
}
