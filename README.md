# MinIO Azure Container App

This repo deploys a MinIO Container to an **Azure Container Group** with nginx as a reverse proxy for SSL termination and security.

---

## Architecture

```mermaid
flowchart TD
    subgraph External
        A[External Traffic<br>HTTPS:443 / 9443<br>HTTP:80]
    end

    A --> B[Nginx Container<br>Ports: 80,443,9443<br>SSL Termination & Reverse Proxy]

    B --> C[ModSecurity WAF UI<br>Ports: 8080 / 8443<br>Backend → MinIO UI]
    B --> D[ModSecurity WAF API<br>Ports: 9444<br>Backend → MinIO API]

    C --> E[MinIO UI<br>Port 9001]
    D --> F[MinIO API<br>Port 9000]

    E --> G[Azure File Share / Storage Account]
    F --> G
```

---

## Components

* **MinIO Container**: Runs the object storage service (ports 9000/9001 - internal only)
* **nginx Container**: Provides SSL termination and reverse proxy (ports 80/443/9443 - externally exposed)
* **WAF Containers**: ModSecurity CRS protects UI (8080/8443) and API (9444)
* **Storage**: Uses Azure File Share for persistent data storage

---

## Requirements

* Azure Subscription
* Azure Resource Group
* SSL Certificate (.pfx file) for HTTPS traffic
* OpenSSL (for certificate extraction)

---

## Creating the PFX Certificate

1. **Generate a private key:**

   ```bash
   openssl genrsa -out server.key 2048
   ```

2. **Create a certificate signing request (CSR):**

   ```bash
   openssl req -new -key server.key -out server.csr
   ```

   Ensure the Common Name matches your domain.

3. **Generate a self-signed certificate (or use a CA-signed certificate):**

   ```bash
   openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
   ```

4. **Create the PFX file:**

   ```bash
   openssl pkcs12 -export -out minio-cert.pfx -inkey server.key -in server.crt
   ```

5. **Extract certificate and key from PFX:**

   ```bash
   openssl pkcs12 -in minio-cert.pfx -clcerts -nokeys -out server.crt -passin pass:YOUR_PFX_PASSWORD
   openssl pkcs12 -in minio-cert.pfx -nocerts -nodes -out server.key -passin pass:YOUR_PFX_PASSWORD
   ```

---

## Usage

### Accessing MinIO

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
   mc mb myminio/my-bucket
   mc ls myminio
   mc cp myfile.txt myminio/my-bucket/
   mc cp myminio/my-bucket/myfile.txt ./
   ```

### Using AWS CLI

```bash
aws s3 ls --endpoint-url https://your-domain.region.azurecontainer.io:9443 --no-verify-ssl
```

---

## Resources Created

* **Container Group**: Hosts MinIO and nginx containers
* **Storage Account**: Provides persistent storage
* **Storage Share**: Azure File Share for MinIO data
* **Log Analytics Workspace**: For monitoring and logs
* **Network Security**: All MinIO ports are internal-only, external access via nginx SSL proxy

---

## Security Features

* **SSL Termination**: All traffic encrypted via nginx
* **No Direct MinIO Access**: MinIO ports not exposed externally
* **Certificate-based Authentication**: Uses SSL certificates for secure connections
* **Internal Communication**: Containers communicate via localhost within the container group
