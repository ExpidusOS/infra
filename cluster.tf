data "google_container_cluster" "infra" {
  name = "infra-${var.region}"
  location = var.region
}

provider "kubernetes" {
  host = data.google_container_cluster.infra.endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.infra.master_auth[0].cluster_ca_certificate)
}
