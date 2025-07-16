# MinIO Azure Container App

This repo deploys a MinIO Container to Azure Container Apps. It pulls the MinIO Container Image from Dockerhub

## Requirements
- Azure Subscription
- Microsoft.App Resource Provider enabled

## Resources That Are Created
- VNET
- Subnet
- WAF Policy
- Application Gateway
- Storage Account
- Azure Storage
- Log Analytics Workspace
- Container App Environment
- Container App

## Inputs
- **minio_root_user**: Root User for MinIO access
- **minio_root_password**: Root Password for MinIO
- **ingress_allow_ip_address_range**: Allowlist of IPs/IP Ranges that can access MinIO

## How to deploy
- `terraform apply`

## TODO
#### Secrets
- Extract secrets from files and store in
  - Key Vault?
  - Github Secrets?

- Automate Deployment
  - Building Block Deployment