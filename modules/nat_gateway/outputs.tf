output "nat_gateway_ids" {
  description = "AZサフィックス → NAT GW IDのマップ  例) { \"1a\" = \"ngw-xxx\" }"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "eip_public_ips" {
  description = "AZサフィックス → EIPパブリックアドレスのマップ"
  value       = { for k, v in aws_eip.this : k => v.public_ip }
}
