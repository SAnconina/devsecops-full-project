output "namespace_name" {
  description = "Nom du namespace Kubernetes géré par Terraform"
  value       = kubernetes_namespace.devsecops.metadata[0].name
}

output "kubernetes_context" {
  description = "Contexte Kubernetes utilisé"
  value       = var.kubernetes_context
}
