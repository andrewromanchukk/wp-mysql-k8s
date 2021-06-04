
#export TF_VAR_cred_gcp="/home/andrii/dev/igneous-sum-312016-e077e9ecd90a.json"
# variable "region" {
#   default = "europe-west1"
# }

# variable "zone" {
#   default = "europe-west1-c"
# }

variable "sql_user_password" {
  default = "1234"
}
# export GOOGLE_APPLICATION_CREDENTIALS="/home/andrii/dev/gcp_key.json"


variable "gcp_credentials" {
  type = string
  description = "Location of service account for GCP"
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gke_cluster_name" {
  type = string
  description = "GKE Cluster name"
}

variable "gke_zones" {
  type = list(string)
  description = "List of zones for the GKE Cluster"
}

variable "gke_network" {
  type = string
  description = "VPC network name"
}
variable "gke_subnetwork" {
  type = string
  description = "Subnetwork name"
}

variable "gke_default_nodepool_name" {
  type = string
}

variable "gcp_service_account" {
  type = string
}

variable "gke_regional" {
  default = false
}