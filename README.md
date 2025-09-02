# MinIO Azure Container App

This repo deploys a MinIO Container to Azure Container Apps. The App will utilize a Web Application Firewall (WAF) for security and an Application Gateway for load balancing.

## Requirements
- Azure Subscription
- Microsoft.App Resource Provider enabled on the Azure Subscription
  - Follow the steps here to register "Microsoft.App"https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider-1
- SSL Cert (.pfx file) added to folder structure with name `minioapp.pfx`

## To Use
- Create a Terraform Building Block Definition
- Select Azure as the Supported Platform
- How often can this Building Block be assigned?: Once
- **Git Repository URL**: https://github.com/meshcloud/minio_azure_container_app.git

## Inputs
- **minio_root_user**: Root User for MinIO access
- **minio_root_password**: Root Password for MinIO
- **ingress_allow_ip_address_range**: Allowlist of IPs/IP Ranges that can access MinIO
- **vnet_cidr_range**: CIDR Range to use for VNET creation. Example: 10.0.0.0/16
- **subnet_cidr_range**: Subnet CIDR Range used for Container Application. Must be at minimum /23. Example: 10.0.0.0/23
- **ag_subnet_cidr_range**: Subnet CIDR Range used for Application Gateway. Must be at minimum /23. Example: 10.0.10.0/23

## Outputs
- **azurerm_container_app_url**: The URL for the MinIO Console
- **public_ip_address**: The IP address of the MinIO Console
- **application_gateway_id**: The ID of the Application Gateway that was created

## Resources That Are Created
- VNET
- Subnet
- WAF Policy
- Application Gateway
- Storage Account
- Azure Storage
- Log Analytics Workspace
- Container Group