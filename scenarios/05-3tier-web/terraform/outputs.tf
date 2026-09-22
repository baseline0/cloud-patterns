output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the ALB"
}

output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "RDS endpoint"
}

output "asg_name" {
  value       = aws_autoscaling_group.app.name
  description = "Auto Scaling Group name"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}
