terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.7"
    }
  }
}
