output "region" {
  value = var.aws_region
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}

output "context_bucket" {
  value = aws_s3_bucket.context.bucket
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.address
}

output "postgres_secret_arn" {
  value     = aws_secretsmanager_secret.db.arn
  sensitive = true
}
