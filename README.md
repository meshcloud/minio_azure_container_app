# MinIO Azure Container App

This repo deploys a MinIO Container to Azure Container Apps. The App will utilize a Web Application Firewall (WAF) for security and an Application Gateway for load balancing.

## Requirements
- Azure Subscription
- Microsoft.App Resource Provider enabled on Azure Subscription

## Inputs
- **minio_root_user**: Root User for MinIO access
- **minio_root_password**: Root Password for MinIO
- **ingress_allow_ip_address_range**: Allowlist of IPs/IP Ranges that can access MinIO

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