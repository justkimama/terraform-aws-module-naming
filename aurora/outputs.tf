output "cluster_endpoint" {
  description = "Aurora クラスターの Writer エンドポイント"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "Aurora クラスターの Reader エンドポイント"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "cluster_arn" {
  description = "Aurora クラスター ARN"
  value       = aws_rds_cluster.this.arn
}

output "cluster_identifier" {
  description = "Aurora クラスター識別子"
  value       = aws_rds_cluster.this.cluster_identifier
}

output "global_cluster_identifier" {
  description = "Aurora グローバルクラスター識別子"
  value       = aws_rds_global_cluster.this.global_cluster_identifier
}

output "cluster_port" {
  description = "Aurora クラスターのポート番号"
  value       = aws_rds_cluster.this.port
}

output "master_user_secret_arn" {
  description = "マスターパスワード Secret ARN (Secrets Manager)"
  value       = aws_secretsmanager_secret.master_password.arn
}
