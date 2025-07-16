# MinIO Azure Container App

This repo deploys a MinIO Container to Azure Container Apps. The App will utilize a Web Application Firewall (WAF) for security and an Application Gateway for load balancing.

## Requirements
- Azure Subscription
- Microsoft.App Resource Provider enabled on Azure Subscription
- Virtual Network
- 2 Subnets
  - 1 Subnet for the Container App
    - Private link Service Network Policies **disabled**
      - `az network vnet subnet update \
          --name default \
          --vnet-name MyVnet \
          --resource-group myResourceGroup \
          --disable-private-link-service-network-policies yes`
    - Microsoft.Storage Service Endpoint **enabled**
  - 1 Subnet exclusively for Application Gateways
    - Microsoft.Storage Service Endpoint **enabled**

## To Use
- Create a Terraform Building Block Definition
- Select Azure as the Supported Platform
- How often can this Building Block be assigned?: Once
- **Git Repository URL**: https://github.com/meshcloud/minio_azure_container_app.git

## Inputs
- **minio_root_user**: Root User for MinIO access
- **minio_root_password**: Root Password for MinIO
- **ingress_allow_ip_address_range**: Allowlist of IPs/IP Ranges that can access MinIO
- **vnet_name**: Name of the existing VNET to be used
- **subnet_name**: Name of the existing Subnet to be used for the Azure Container App
- **ag_subnet_name**: Name of the existing Subnet to be used for the Application Gateway

## Outputs
- **azurerm_container_app_url**: The URL for the MinIO Console
- **public_ip_address**: The IP address of the MinIO Console
- **application_gateway_id**: The ID of the Application Gateway that was created

## Resources That Are Created
- WAF Policy
- Application Gateway
- Storage Account
- Azure Storage
- Log Analytics Workspace
- Container App Environment
- Container App