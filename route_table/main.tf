locals {
  # Protected subnet の AZ に NAT GW がない場合は先頭 (= 最も若い AZ) の NAT GW にフォールバック
  # engineering-dev: NAT GW が "1a" のみ → 全 Protected subnet が "1a" の RTB を使う
  # prd: 各 AZ に NAT GW → その AZ の RTB を使う
  first_nat_az = keys(var.nat_gateways)[0]

  subnet_to_nat_az = {
    for az, subnet_id in var.protected_subnets_by_az :
    az => contains(keys(var.nat_gateways), az) ? az : local.first_nat_az
  }
}

# --- Public: デフォルトルート → IGW ---
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rtb-public" })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# --- Protected: デフォルトルート → NAT GW (AZ ごとに 1 台) ---
# ルートテーブルを NAT GW の数だけ作成し、各 Protected subnet を対応する RTB に紐付ける
resource "aws_route_table" "protected" {
  for_each = var.nat_gateways

  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rtb-protected-${each.key}" })
}

resource "aws_route_table_association" "protected" {
  for_each = var.protected_subnets_by_az

  subnet_id      = each.value
  route_table_id = aws_route_table.protected[local.subnet_to_nat_az[each.key]].id
}

# --- Private: インターネット経路なし ---
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-rtb-private" })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_ids)

  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}
