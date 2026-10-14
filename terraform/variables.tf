variable "kubeconfig_path" {
  description = "Chemin du fichier de configuration Kubernetes"
  type        = string
  default     = "~/.kube/config"
}

variable "kubernetes_context" {
  description = "Contexte Kubernetes à utiliser"
  type        = string
  default     = "kind-devsecops"
}

variable "namespace" {
  description = "Namespace Kubernetes géré par Terraform"
  type        = string
  default     = "devsecops"
}
