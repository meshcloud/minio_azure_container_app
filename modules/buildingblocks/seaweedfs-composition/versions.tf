terraform {
  required_version = ">= 1.6.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19"
    }
  }
}
