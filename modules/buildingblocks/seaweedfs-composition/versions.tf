terraform {
  required_version = ">= 1.8"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}
