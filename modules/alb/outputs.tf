output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB の DNS 名"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB の Route53 Hosted Zone ID"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ターゲットグループ ARN (ECS サービスから参照)"
  value       = aws_lb_target_group.this.arn
}

output "http_listener_arn" {
  description = "HTTP リスナー ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS リスナー ARN (未作成時は null)"
  value       = try(aws_lb_listener.https[0].arn, null)
}
