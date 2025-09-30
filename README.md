# MinIO Azure Container App

This repo deploys a MinIO Container to an Azure Container Group with nginx as a reverse proxy for SSL termination and security.

## Architecture

- **MinIO Container**: Runs the object storage service (ports 9000/9001 - internal only)
- **nginx Container**: Provides SSL termination and reverse proxy (ports 80/443/9443 - externally exposed)
- **Security**: All MinIO ports are internal-only, all external traffic goes through nginx with SSL
- **Storage**: Uses Azure File Share for persistent data storage

## Requirements
- Azure Subscription
- Azure Resource Group
- SSL Certificate (.pfx file) for HTTPS traffic
- OpenSSL (for certificate extraction)

## Creating the PFX Certificate

To create a PFX certificate for the MinIO service, you can use OpenSSL with the following steps:

1. **Generate a private key:**
   ```bash
   openssl genrsa -out server.key 2048
   ```

2. **Create a certificate signing request (CSR):**
   ```bash
   openssl req -new -key server.key -out server.csr
   ```
   Fill in the required information when prompted, ensuring the Common Name matches your domain.

3. **Generate a self-signed certificate (or use a CA-signed certificate):**
   ```bash
   openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
   ```

4. **Create the PFX file:**
   ```bash
   openssl pkcs12 -export -out minio-cert.pfx -inkey server.key -in server.crt
   ```
   You'll be prompted to enter an export password - remember this as it will be needed for the `cert_password` input variable.

5. **Extract certificate and key from PFX (required before deployment):**
   ```bash
   openssl pkcs12 -in minio-cert.pfx -clcerts -nokeys -out server.crt -passin pass:YOUR_PFX_PASSWORD
   openssl pkcs12 -in minio-cert.pfx -nocerts -nodes -out server.key -passin pass:YOUR_PFX_PASSWORD
   ```
   Replace `YOUR_PFX_PASSWORD` with the password you set when creating the PFX file.

**Note:** For production environments, it's recommended to use a certificate from a trusted Certificate Authority rather than a self-signed certificate.

## To Use
- Create a Terraform Building Block Definition
- Select Azure as the Supported Platform
- How often can this Building Block be assigned?: Once
- **Git Repository URL**: https://github.com/meshcloud/minio_azure_container_app.git
- Upload the SSL Cert as a Static Input with a File Type

## Inputs
- **minio_root_user**: Root User for MinIO access
- **minio_root_password**: Root Password for MinIO
- **resource_group_name**: Name of the Resource Group for all new resources
- **location**: Azure region for deployment
- **cert_name**: The name of the SSL certificate (e.g., minio-cert.pfx)
- **cert_password**: The password for the SSL certificate
- **storage_share_size**: Storage space needed in GBs (minimum 1GB, maximum 5120GB/5TB)
- **storage_account_name**: Storage Account Name (must be globally unique across Azure)
- **public_url_domain_name**: Domain name for the public URL (e.g., 'miniotest' creates 'testminio.westeurope.azurecontainer.io')

## Outputs
- **console_url**: The URL address of the MinIO Console (Web UI)
- **api_url**: The URL address of the MinIO S3 API
- **minio_username**: The MinIO root username

## Usage

### Accessing MinIO
After deployment, you can access MinIO through:

**Web Console (UI):**
```
https://your-domain.region.azurecontainer.io/
```

**S3 API (for applications/tools):**
```
https://your-domain.region.azurecontainer.io:9443/
```

### Using MinIO Client (mc)
1. **Install MinIO Client:**
   ```bash
   # macOS
   brew install minio/stable/mc

   # Linux
   wget https://dl.min.io/client/mc/release/linux-amd64/mc
   chmod +x mc
   ```

2. **Configure MinIO Client:**
   ```bash
   mc alias set myminio https://your-domain.region.azurecontainer.io:9443 your-username your-password --insecure
   ```

3. **Create and manage buckets:**
   ```bash
   # Create a bucket
   mc mb myminio/my-bucket
   
   # List buckets
   mc ls myminio
   
   # Upload files
   mc cp myfile.txt myminio/my-bucket/
   
   # Download files
   mc cp myminio/my-bucket/myfile.txt ./
   ```

### Using AWS CLI
You can also use the AWS CLI with MinIO:
```bash
aws s3 ls --endpoint-url https://your-domain.region.azurecontainer.io:9443 --no-verify-ssl
```

## Resources Created
- **Container Group**: Hosts MinIO and nginx containers
- **Storage Account**: Provides persistent storage
- **Storage Share**: Azure File Share for MinIO data
- **Log Analytics Workspace**: For monitoring and logs
- **Network Security**: All MinIO ports are internal-only, external access via nginx SSL proxy

## Security Features
- **SSL Termination**: All traffic encrypted via nginx
- **No Direct MinIO Access**: MinIO ports not exposed externally
- **Certificate-based Authentication**: Uses SSL certificates for secure connections
- **Internal Communication**: Containers communicate via localhost within the container group
