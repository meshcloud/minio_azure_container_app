# MinIO Azure Container App

This repo deploys a MinIO Container to an Azure Container Group. The App will utilize an Application Gateway with WAF policies for security and load balancing.

## Requirements
- Azure Subscription
- Microsoft.App Resource Provider enabled on the Azure Subscription
  - Follow the steps here to register "Microsoft.App"https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider-1
- SSL Cert (.pfx file) for https traffic. Password will be provided as Input Variable

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
- **cert_name**: The name of the SSL certificate
- **cert_password**: The password for the SSL certificate
- **storage_share_size**: How much storage space do you need in GBs? Minimun size is 1GB and Maximum is 5120GB (5TB)
- **storage_account_name**: Storage Account Name. Must be globally unique across Azure Region. Suggest using Project Name
- **public_url_domain_name**: Domain Name to use for the public URL. Example: 'miniotest' would allow you to access MinIO from the URL 'https://miniotest.westeurope.cloudapp.azure.com'

## Outputs
- **platform_tenant_id**: The Building Block unique identifier used by meshcloud
- **console_url**: The URL address of the MinIO Console
- **api_url**: The URL address of the MinIO API

## Resources That Are Created
- VNET
- Subnet
- WAF Policy
- Application Gateway
- Storage Account
- Azure Storage
- Log Analytics Workspace
- Container Group