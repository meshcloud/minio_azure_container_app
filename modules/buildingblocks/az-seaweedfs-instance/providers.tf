provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = var.deployer_token
}

# Authenticates via ARM_* environment variables (ARM_TENANT_ID,
# ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET) injected by meshStack
# from the scoped DNS Service Principal — no explicit credentials needed here.
provider "azurerm" {
  features {}
}
