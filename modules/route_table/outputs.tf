output "public_route_table_id" {
  description = "Public ルートテーブル ID"
  value       = aws_route_table.public.id
}

output "protected_route_table_ids" {
  description = "AZサフィックス → Protected ルートテーブル ID のマップ  例) { \"1a\" = \"rtb-xxx\" }"
  value       = { for k, v in aws_route_table.protected : k => v.id }
}

output "private_route_table_id" {
  description = "Private ルートテーブル ID"
  value       = aws_route_table.private.id
}
