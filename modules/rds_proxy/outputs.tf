output "proxy_endpoint" {
  description = "RDS Proxy の読み書きエンドポイント (Writer 接続先)"
  value       = aws_db_proxy.this.endpoint
}

output "proxy_read_only_endpoint" {
  description = "RDS Proxy の読み取り専用エンドポイント (Reader 接続先)"
  value       = aws_db_proxy_endpoint.read_only.endpoint
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = aws_db_proxy.this.arn
}
