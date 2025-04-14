# Declare Variables
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  default     = "cluster-2"
}

variable "region" {
  description = "The region for the Kubernetes cluster"
  default     = "us-central1-c"
}

variable "node_count" {
  description = "The number of nodes in the cluster"
  type        = number  # Change type to number
  default     = 2
}

variable "node_machine_type" {
  description = "The type of machine to use for nodes in the Kubernetes cluster"
  type        = string
  default     = "e2-standard-4"
}
