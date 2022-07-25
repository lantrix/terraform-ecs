output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.techdebug.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = aws_ecs_cluster.techdebug.id
}
