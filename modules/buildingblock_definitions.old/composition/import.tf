terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.22.0"
    }
  }
}

provider "meshstack" {
  endpoint  = "https://federation.prod.meshcloud.io"
  apikey    = "086d82ac-bbe1-47e3-9697-6aa49c75db52"
  apisecret = "OB7fkMz4Z1wpPumxGqABwwgBrWhoDK7l"
}

import {
  id = "6dfc94ef-8d7c-48f9-8990-b455f9979354" # replace with your actual UUID
  to = meshstack_building_block_definition.howto_example
}


# resource "meshstack_building_block_definition" "howtoexample" {}
