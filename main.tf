terraform {
  required_version = ">= 1.5.4"
  backend "s3" {
    bucket = "expidusos-ci"
    key = "infra/terraform.tfstate"
    endpoint = "https://s3.wasabisys.com"
    region = "us-west-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
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
