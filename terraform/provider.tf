provider "google" {
  credentials = file("gcp-key") # GCP service account
  project     = var.project_id
  region      = var.region
}
