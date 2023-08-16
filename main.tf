terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.78.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

variable "region" {
  type = string
  nullable = false
}

provider "google" {
  project = "expidusos-infra"
  region = var.region
}

data "google_client_config" "default" {}
