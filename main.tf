terraform {
  backend "s3" {
    bucket = "expidusos-ci"
    endpoint = "s3.us-west-1.wasabisys.com"
    region = "us-west-1"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.78.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.7.0"
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
