{
  "realm": "minio_realm",
  "enabled": true,
  "users": [
    {
      "username": "${test_user_username}",
      "email": "${test_user_email}",
      "firstName": "Sarah",
      "lastName": "Connor",
      "enabled": true,
      "emailVerified": true,
      "credentials": [
        {
          "type": "password",
          "value": "${test_user_password}",
          "temporary": false
        }
      ],
      "realmRoles": [
        "readonly"
      ]
    }
  ],
  "clients": [
    {
      "clientId": "minio-client",
      "name": "MinIO OIDC Client",
      "secret": "${minio_client_secret}",
      "enabled": true,
      "protocol": "openid-connect",
      "clientAuthenticatorType": "client-secret",
      "publicClient": false,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": false,
      "serviceAccountsEnabled": false,
      "standardFlowEnabled": true,
      "rootUrl": "https://${fqdn}",
      "redirectUris": [
        "https://${fqdn}/oauth_callback"
      ],
      "webOrigins": [
        "https://${fqdn}"
      ],
      "defaultClientScopes": [
        "openid",
        "profile",
        "email"
      ],
      "optionalClientScopes": [
        "offline_access"
      ],
      "protocolMappers": [
        {
          "name": "realm-role-mapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-usermodel-realm-role-mapper",
          "consentRequired": false,
          "config": {
            "introspection.token.claim": "true",
            "multivalued": "true",
            "userinfo.token.claim": "true",
            "id.token.claim": "true",
            "lightweight.claim": "false",
            "access.token.claim": "true",
            "claim.name": "policy",
            "jsonType.label": "String"
          }
        },
        {
          "name": "security-admin-audience-mapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-audience-mapper",
          "config": {
            "included.client.audience": "security-admin-console",
            "id.token.claim": "true",
            "access.token.claim": "true"
          }
        }
      ]
    },
    {
      "clientId": "opkssh-client",
      "name": "OpenPubkey SSH Client",
      "enabled": true,
      "protocol": "openid-connect",
      "publicClient": true,
      "directAccessGrantsEnabled": false,
      "standardFlowEnabled": true,
      "redirectUris": ${opkssh_redirect_uris},
      "webOrigins": [
        "+"
      ],
      "defaultClientScopes": [
        "openid",
        "profile",
        "email"
      ]
    }
  ],
  "roles": {
    "realm": [
      {
        "name": "readonly",
        "description": "This role provides read only access to all buckets",
        "composite": false,
        "clientRole": false,
        "attributes": {}
      }
    ]
  }
}
