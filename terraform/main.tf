# main.tf
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  deletion_protection = true

  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = 20
  }

  remove_default_node_pool = false
}

# Variables file
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region for the Kubernetes cluster"
  type        = string
}

variable "zone" {
  description = "The zone for the Kubernetes cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "gke-cluster"
}

variable "node_count" {
  description = "The number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "node_machine_type" {
  description = "The type of machine to use for nodes"
  type        = string
  default     = "e2-medium"
}
