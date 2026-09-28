# --------------------------------------------------
# Terraform Outputs
# --------------------------------------------------

output "vpc_id" {
  description = "ID of the Fider VPC"
  value       = aws_vpc.fider_vpc.id
}

output "ecr_repository_url" {
  description = "URL of the Fider ECR repository"
  value       = aws_ecr_repository.fider.repository_url
}

output "rds_endpoint" {
  description = "Endpoint of the Fider PostgreSQL database"
  value       = aws_db_instance.fider.address
}

output "ecs_cluster_name" {
  description = "Name of the Fider ECS cluster"
  value       = aws_ecs_cluster.fider.name
}

output "ecs_service_name" {
  description = "Name of the Fider ECS service"
  value       = aws_ecs_service.fider.name
}

output "alb_dns_name" {
  description = "DNS name of the Fider Application Load Balancer"
  value       = aws_lb.fider.dns_name
}

output "fider_url" {
  description = "Public HTTPS URL for Fider"
  value       = "https://${var.domain_name}"
}
