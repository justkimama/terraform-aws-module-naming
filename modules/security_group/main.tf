locals {
  # cidr_blocks が複数の場合は "<rule_key>_<index>" に展開、1つ以下はキー名そのまま (後方互換)
  _ingress_expanded = { for entry in flatten([
    for rule_key, rule in var.ingress_rules :
    length(rule.cidr_blocks) <= 1 ? [{
      key       = rule_key
      desc      = rule.description
      from_port = rule.from_port
      to_port   = rule.to_port
      protocol  = rule.protocol
      cidr_ipv4 = length(rule.cidr_blocks) == 1 ? rule.cidr_blocks[0] : null
      sg_id     = rule.source_security_group_id
      }] : [
      for cidr in rule.cidr_blocks : {
        key       = "${rule_key}_${cidr}"
        desc      = rule.description
        from_port = rule.from_port
        to_port   = rule.to_port
        protocol  = rule.protocol
        cidr_ipv4 = cidr
        sg_id     = rule.source_security_group_id
      }
    ]
  ]) : entry.key => entry }

  _egress_expanded = { for entry in flatten([
    for rule_key, rule in var.egress_rules :
    length(rule.cidr_blocks) <= 1 ? [{
      key       = rule_key
      desc      = rule.description
      from_port = rule.from_port
      to_port   = rule.to_port
      protocol  = rule.protocol
      cidr_ipv4 = length(rule.cidr_blocks) == 1 ? rule.cidr_blocks[0] : null
      sg_id     = rule.source_security_group_id
      }] : [
      for cidr in rule.cidr_blocks : {
        key       = "${rule_key}_${cidr}"
        desc      = rule.description
        from_port = rule.from_port
        to_port   = rule.to_port
        protocol  = rule.protocol
        cidr_ipv4 = cidr
        sg_id     = rule.source_security_group_id
      }
    ]
  ]) : entry.key => entry }
}

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local._ingress_expanded

  security_group_id            = aws_security_group.this.id
  description                  = each.value.desc
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.sg_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local._egress_expanded

  security_group_id            = aws_security_group.this.id
  description                  = each.value.desc
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.sg_id
}
