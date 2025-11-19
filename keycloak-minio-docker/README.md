Here is the polished and spell-checked version of your markdown text:

## Setup

The **Keycloak** container must be running before the **MinIO** container starts up. It takes a few minutes for **Keycloak** and **Postgres** to fully bootstrap.

The file `minio-realm-config.json` is imported at boot and creates the following configuration:

  * Realm: `minio_realm`
  * Realm Role: `readonly`
  * OpenID Client: `minio-client`
  * Mapper for `minio-client` mapping the user's **Realm Role** to the token attribute `"policy"`.
  * Client User: `testuser` with the assigned role `readonly`.

-----

## Credentials

**MinIO** admin credentials, along with the credentials for **Keycloak** and **Postgres**, are specified in the `docker-compose.yaml` file and `init.env`.

The credentials for the **test user** are specified within the `minio-realm-config.json` file.

-----

## Start

Initialize environment variables:

```bash
source init.env
```

Start the **Keycloak** and **Postgres** containers:

```bash
docker compose -f keycloak.yaml up
```

Once **Keycloak** is running and available, start **MinIO**:

```bash
docker compose -f minio.yaml up
```