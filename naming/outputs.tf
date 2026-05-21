# --- 汎用 (動的リソース / for_each で複数生成するもの) ---
output "prefix" {
  description = "{project}-{env_abbr} 形式のプレフィックス  例) pj-dev"
  value       = local.prefix
}

output "env_abbr" {
  description = "環境名の略称  例) edev"
  value       = local.env_abbr
}

# --- 静的リソース名 (1環境に1個しか存在しないリソース) ---
output "vpc_name" {
  description = "VPC名  例) pj-dev-vpc"
  value       = "${local.prefix}-vpc"
}

output "igw_name" {
  description = "Internet Gateway名"
  value       = "${local.prefix}-igw"
}

output "alb_control_nginx_name" {
  description = "Control-Nginx ALB名 (CloudFront → Control-Nginx ECS 向け)"
  value       = "${local.prefix}-alb-control-nginx"
}

output "alb_backend_api_name" {
  description = "Backend-API ALB名 (Control-Nginx ECS → Backend-API ECS 向け)"
  value       = "${local.prefix}-alb-backend-api"
}

output "ecs_control_nginx_cluster_name" {
  description = "Control-Nginx ECS Cluster名  例) pj-dev-ecscluster-control-nginx"
  value       = "${local.prefix}-ecscluster-control-nginx"
}

output "ecs_control_nginx_exec_role_name" {
  description = "Control-Nginx ECS Task Execution Role名  例) pj-dev-iamrole-ecs-control-nginx-taskexec"
  value       = "${local.prefix}-iamrole-ecs-control-nginx-taskexec"
}

output "ecs_control_nginx_task_role_name" {
  description = "Control-Nginx ECS Task Role名  例) pj-dev-iamrole-ecs-control-nginx-task"
  value       = "${local.prefix}-iamrole-ecs-control-nginx-task"
}

output "ecs_control_nginx_exec_secrets_policy_name" {
  description = "Control-Nginx Secrets Manager参照ポリシー名  例) pj-dev-iampolicy-ecs-control-nginx-taskexec-secrets"
  value       = "${local.prefix}-iampolicy-ecs-control-nginx-taskexec-secrets"
}

output "ecs_control_nginx_log_group_name" {
  description = "Control-Nginx CloudWatch Log Group名  例) /ecs/pj-dev/control-nginx"
  value       = "/ecs/${local.prefix}/control-nginx"
}

output "ecs_control_nginx_service_name" {
  description = "Control-Nginx ECS Service名  例) pj-dev-ecssvc-control-nginx"
  value       = "${local.prefix}-ecssvc-control-nginx"
}

output "ecs_control_nginx_task_name" {
  description = "Control-Nginx ECS Task Definition名  例) pj-dev-ecstask-control-nginx"
  value       = "${local.prefix}-ecstask-control-nginx"
}

output "ecs_backend_api_cluster_name" {
  description = "Backend-API ECS Cluster名  例) pj-dev-ecscluster-backend-api"
  value       = "${local.prefix}-ecscluster-backend-api"
}

output "ecs_backend_api_exec_role_name" {
  description = "Backend-API ECS Task Execution Role名  例) pj-dev-iamrole-ecs-backend-api-taskexec"
  value       = "${local.prefix}-iamrole-ecs-backend-api-taskexec"
}

output "ecs_backend_api_task_role_name" {
  description = "Backend-API ECS Task Role名  例) pj-dev-iamrole-ecs-backend-api-task"
  value       = "${local.prefix}-iamrole-ecs-backend-api-task"
}

output "ecs_backend_api_exec_secrets_policy_name" {
  description = "Backend-API Secrets Manager参照ポリシー名  例) pj-dev-iampolicy-ecs-backend-api-taskexec-secrets"
  value       = "${local.prefix}-iampolicy-ecs-backend-api-taskexec-secrets"
}

output "ecs_backend_api_log_group_name" {
  description = "Backend-API CloudWatch Log Group名  例) /ecs/pj-dev/backend-api"
  value       = "/ecs/${local.prefix}/backend-api"
}

output "ecs_backend_api_service_name" {
  description = "Backend-API ECS Service名  例) pj-dev-ecssvc-backend-api"
  value       = "${local.prefix}-ecssvc-backend-api"
}

output "ecs_backend_api_task_name" {
  description = "Backend-API ECS Task Definition名  例) pj-dev-ecstask-backend-api"
  value       = "${local.prefix}-ecstask-backend-api"
}

output "ecr_control_nginx_name" {
  description = "Control-Nginx ECR リポジトリ名  例) pj-dev-ecrrepo-control-nginx"
  value       = "${local.prefix}-ecrrepo-control-nginx"
}

output "ecr_backend_api_name" {
  description = "Backend-API ECR リポジトリ名  例) pj-dev-ecrrepo-backend-api"
  value       = "${local.prefix}-ecrrepo-backend-api"
}

output "aurora_cluster_identifier" {
  description = "Aurora クラスター識別子  例) pj-dev-aurora-cluster"
  value       = "${local.prefix}-aurora-cluster"
}

output "aurora_global_cluster_identifier" {
  description = "Aurora グローバルクラスター識別子  例) pj-dev-aurora-global"
  value       = "${local.prefix}-aurora-global"
}

output "aurora_instance_identifier_prefix" {
  description = "Aurora インスタンス識別子プレフィックス  例) pj-dev-aurora-instance"
  value       = "${local.prefix}-aurora-instance"
}

output "aurora_subnet_group_name" {
  description = "Aurora DB サブネットグループ名  例) pj-dev-aurora-subnetgroup"
  value       = "${local.prefix}-aurora-subnetgroup"
}

output "aurora_parameter_group_name" {
  description = "Aurora クラスターパラメータグループ名  例) pj-dev-aurora-cluster-pg"
  value       = "${local.prefix}-aurora-cluster-pg"
}

output "aurora_master_password_secret_name" {
  description = "Aurora マスターパスワード Secrets Manager 名  例) pj-dev-secret-aurora-master-password"
  value       = "${local.prefix}-secret-aurora-master-password"
}

# --- RDS Proxy ---
output "rds_proxy_name" {
  description = "RDS Proxy 名  例) pj-dev-rdsproxy"
  value       = "${local.prefix}-rdsproxy"
}

output "rds_proxy_role_name" {
  description = "RDS Proxy 用 IAM ロール名  例) pj-dev-iamrole-rdsproxy"
  value       = "${local.prefix}-iamrole-rdsproxy"
}

output "rds_proxy_policy_name" {
  description = "RDS Proxy Secrets Manager 参照ポリシー名  例) pj-dev-iampolicy-rdsproxy-secrets"
  value       = "${local.prefix}-iampolicy-rdsproxy-secrets"
}

output "rds_proxy_read_only_endpoint_name" {
  description = "RDS Proxy 読み取り専用エンドポイント名  例) pj-dev-rdsproxy-read-only"
  value       = "${local.prefix}-rdsproxy-read-only"
}

# --- Cognito ---
output "cognito_user_pool_name" {
  description = "Cognito User Pool 名  例) pj-dev-cognito-user-pool"
  value       = "${local.prefix}-cognito-user-pool"
}

# --- S3 ---
output "s3_frontend_bucket_name" {
  description = "フロントエンド CSR ホスティング用 S3 バケット名  例) pj-dev-s3-frontend"
  value       = "${local.prefix}-s3-frontend"
}

output "s3_frontend_manage_bucket_name" {
  description = "管理画面フロントエンド CSR ホスティング用 S3 バケット名  例) pj-dev-s3-frontend-manage"
  value       = "${local.prefix}-s3-frontend-manage"
}

# --- CloudFront ---
output "cloudfront_oac_name" {
  description = "CloudFront Origin Access Control 名  例) pj-dev-cfoac-frontend"
  value       = "${local.prefix}-cfoac-frontend"
}

output "cloudfront_comment" {
  description = "CloudFront ディストリビューションコメント  例) pj-dev-cf-frontend"
  value       = "${local.prefix}-cf-frontend"
}

output "cloudfront_manage_oac_name" {
  description = "管理画面用 CloudFront Origin Access Control 名  例) pj-dev-cfoac-frontend-manage"
  value       = "${local.prefix}-cfoac-frontend-manage"
}

output "cloudfront_manage_comment" {
  description = "管理画面用 CloudFront ディストリビューションコメント  例) pj-dev-cf-frontend-manage"
  value       = "${local.prefix}-cf-frontend-manage"
}

# --- WAF ---
output "waf_cloudfront_name" {
  description = "WAF Web ACL 名 (CloudFront 用)  例) pj-dev-waf-cloudfront"
  value       = "${local.prefix}-waf-cloudfront"
}

output "waf_alb_front_name" {
  description = "WAF Web ACL 名 (ALB front 用)  例) pj-dev-waf-alb-front"
  value       = "${local.prefix}-waf-alb-front"
}

# --- IAM ---
output "iam_github_actions_role_name" {
  description = "GitHub Actions OIDC IAM Role 名  例) pj-dev-iamrole-github-actions"
  value       = "${local.prefix}-iamrole-github-actions"
}

output "iam_github_actions_ecr_push_policy_name" {
  description = "GitHub Actions ECR Push ポリシー名  例) pj-dev-iampolicy-github-actions-ecr-push"
  value       = "${local.prefix}-iampolicy-github-actions-ecr-push"
}

output "ecs_backend_api_cognito_user_admin_policy_name" {
  description = "Backend-API Cognito ユーザー管理ポリシー名  例) pj-dev-iampolicy-ecs-backend-api-cognito-user-admin"
  value       = "${local.prefix}-iampolicy-ecs-backend-api-cognito-user-admin"
}

# --- System Logs S3 ---
output "s3_syslog_alb_bucket_name" {
  description = "ALB アクセスログ用 S3 バケット名  例) pj-dev-s3-syslog-alb"
  value       = "${local.prefix}-s3-syslog-alb"
}

output "s3_syslog_cloudfront_bucket_name" {
  description = "CloudFront 標準ログ用 S3 バケット名  例) pj-dev-s3-syslog-cloudfront"
  value       = "${local.prefix}-s3-syslog-cloudfront"
}

output "s3_syslog_waf_bucket_name" {
  description = "WAF ログ用 S3 バケット名 (REGIONAL/ap-northeast-1)  例) aws-waf-logs-pj-dev"
  value       = "aws-waf-logs-${local.prefix}"
}

output "s3_syslog_waf_cloudfront_bucket_name" {
  description = "WAF ログ用 S3 バケット名 (CLOUDFRONT/us-east-1)  例) aws-waf-logs-pj-dev-cf"
  value       = "aws-waf-logs-${local.prefix}-cf"
}

output "s3_syslog_ecs_bucket_name" {
  description = "ECS ログ用 S3 バケット名  例) pj-dev-s3-syslog-ecs"
  value       = "${local.prefix}-s3-syslog-ecs"
}

output "firehose_ecs_stream_name" {
  description = "ECS ログ配信用 Firehose ストリーム名  例) pj-dev-firehose-ecs-logs"
  value       = "${local.prefix}-firehose-ecs-logs"
}

output "firehose_ecs_role_name" {
  description = "Firehose が S3 に書き込むための IAM ロール名  例) pj-dev-iamrole-firehose-ecs"
  value       = "${local.prefix}-iamrole-firehose-ecs"
}

output "cw_logs_firehose_role_name" {
  description = "CloudWatch Logs が Firehose に書き込むための IAM ロール名  例) pj-dev-iamrole-cwlogs-firehose-ecs"
  value       = "${local.prefix}-iamrole-cwlogs-firehose-ecs"
}

output "s3_syslog_vpc_flow_bucket_name" {
  description = "VPC Flow Logs 用 S3 バケット名  例) pj-dev-s3-syslog-vpc-flow"
  value       = "${local.prefix}-s3-syslog-vpc-flow"
}
