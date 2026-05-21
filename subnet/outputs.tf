output "subnet_ids" {
  description = "サブネット名 → subnet ID のマップ (例: {\"public-1a\" = \"subnet-xxx\"})"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "public_subnet_ids" {
  description = "Public サブネットのIDリスト"
  value       = [for k, v in aws_subnet.this : v.id if var.subnets[k].tier == "public"]
}

output "protected_subnet_ids" {
  description = "Protected サブネットのIDリスト"
  value       = [for k, v in aws_subnet.this : v.id if var.subnets[k].tier == "protected"]
}

output "private_subnet_ids" {
  description = "Private サブネットのIDリスト"
  value       = [for k, v in aws_subnet.this : v.id if var.subnets[k].tier == "private"]
}

output "protected_subnets_by_az" {
  description = "AZサフィックス → Protected Subnet IDのマップ  例) { \"1a\" = \"subnet-xxx\" }"
  value = {
    for k, v in aws_subnet.this : trimprefix(k, "protected-") => v.id
    if var.subnets[k].tier == "protected"
  }
}
