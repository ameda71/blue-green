provider "google" {
  credentials = file("account.json") # GCP service account
  project     = var.project_id
  region      = var.region
}
