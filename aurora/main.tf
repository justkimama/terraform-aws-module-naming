# ----------------------------------------
# DB Subnet Group
# ----------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = var.subnet_group_name })
}

# ----------------------------------------
# Cluster Parameter Group
# ----------------------------------------
resource "aws_rds_cluster_parameter_group" "this" {
  name   = var.parameter_group_name
  family = "aurora-mysql8.0"

  tags = merge(var.tags, { Name = var.parameter_group_name })
}

# ----------------------------------------
# Global Database
# プライマリクラスターのみで作成。DR時にセカンダリリージョンを追加する。
# ----------------------------------------
resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.global_cluster_identifier
  engine                    = "aurora-mysql"
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = true
  deletion_protection       = var.deletion_protection
}

# ----------------------------------------
# Master Password (Secrets Manager で管理)
# Global Database では manage_master_user_password が使えないため自前管理
# ignore_changes = all の意図:
# random_password のパラメータを変更 → パスワードが再生成
# → master_password の値が変わる → Aurora クラスターに modify がかかる
# この意図しない連鎖を防ぐために全属性の変更を無視する
# ----------------------------------------
resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret" "master_password" {
  name                    = var.master_password_secret_name
  recovery_window_in_days = var.secret_recovery_window_in_days
  tags                    = merge(var.tags, { Name = var.master_password_secret_name })
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id = aws_secretsmanager_secret.master_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

# ----------------------------------------
# Aurora Cluster (Primary)
# Global Database のプライマリクラスター
# ----------------------------------------
resource "aws_rds_cluster" "this" {
  cluster_identifier        = var.cluster_identifier
  global_cluster_identifier = aws_rds_global_cluster.this.id
  engine                    = "aurora-mysql"
  engine_version            = var.engine_version

  master_username = var.master_username
  master_password = random_password.master.result
  port            = 3306

  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  vpc_security_group_ids          = var.security_group_ids

  storage_encrypted            = true
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(var.tags, { Name = var.cluster_identifier })
}

# ----------------------------------------
# Aurora Instance(s)
# ----------------------------------------
resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.instance_identifier_prefix}-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = var.instance_class

  tags = merge(var.tags, { Name = "${var.instance_identifier_prefix}-${count.index}" })
}
