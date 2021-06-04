provider "google" {
#   version = ">= 3.39.0"
  project = var.gcp_project_id
  region  = var.gcp_region
  credentials = file(var.gcp_credentials)
}
data "google_client_config" "default" {}
provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}