data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

data "google_service_account" "default" {
  account_id = "github-ci"
}

resource "google_compute_network" "infra-vpc" {
  name = "infra-${var.region}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "infra-subnet" {
  name = "infra-${var.region}-subnet"
  region = var.region
  network = resource.google_compute_network.infra-vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "infra" {
  name = "infra-${var.region}"
  location = var.region

  remove_default_node_pool = true
  initial_node_count = 1

  network = resource.google_compute_network.infra-vpc.name
  subnetwork = resource.google_compute_subnetwork.infra-subnet.name

  cluster_autoscaling {
    enabled = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"

    resource_limits {
      resource_type = "cpu"
      minimum = 2
      maximum = 24
    }

    resource_limits {
      resource_type = "memory"
      minimum = 8
      maximum = 48
    }
  }

  node_config {
    service_account = data.google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    disk_type = "pd-standard"
    disk_size_gb = 25

    machine_type = "n1-standard-1"
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_container_node_pool" "infra-primary-nodes" {
  name = resource.google_container_cluster.infra.name
  location = var.region
  cluster = resource.google_container_cluster.infra.name
  
  version = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    service_account = data.google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    disk_type = "pd-standard"
    disk_size_gb = 25

    machine_type = "n1-standard-1"
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

provider "kubernetes" {
  host = "https://${resource.google_container_cluster.infra.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(resource.google_container_cluster.infra.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = "https://${resource.google_container_cluster.infra.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(resource.google_container_cluster.infra.master_auth[0].cluster_ca_certificate)
  }
}
