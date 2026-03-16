{
  "realm": "seaweedfs",
  "enabled": true,
  "roles": {
    "realm": [
      { "name": "customer-1" },
      { "name": "customer-2" }
    ]
  },
  "clientScopes": [
    {
      "name": "profile",
      "protocol": "openid-connect",
      "attributes": {
        "include.in.token.scope": "true",
        "display.on.consent.screen": "true"
      },
      "protocolMappers": [
        {
          "name": "username",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-usermodel-property-mapper",
          "config": {
            "user.attribute": "username",
            "claim.name": "username",
            "jsonType.label": "String",
            "id.token.claim": "true",
            "access.token.claim": "true",
            "userinfo.token.claim": "true"
          }
        }
      ]
    },
    {
      "name": "openid",
      "protocol": "openid-connect",
      "attributes": {
        "include.in.token.scope": "true",
        "display.on.consent.screen": "false"
      }
    },
    {
      "name": "seaweed-roles",
      "protocol": "openid-connect",
      "attributes": {
        "include.in.token.scope": "true",
        "display.on.consent.screen": "false"
      },
      "protocolMappers": [
        {
          "name": "realm roles mapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-usermodel-realm-role-mapper",
          "config": {
            "claim.name": "roles",
            "jsonType.label": "String",
            "id.token.claim": "true",
            "access.token.claim": "true",
            "multivalued": "true"
          }
        }
      ]
    },
    {
      "name": "seaweed-audience",
      "protocol": "openid-connect",
      "attributes": {
        "include.in.token.scope": "true",
        "display.on.consent.screen": "false"
      },
      "protocolMappers": [
        {
          "name": "seaweed-audience-mapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-audience-mapper",
          "config": {
            "included.client.audience": "seaweedfs-s3",
            "id.token.claim": "true",
            "access.token.claim": "true"
          }
        }
      ]
    }
  ],
  "clients": [
    {
      "clientId": "seaweedfs-s3",
      "enabled": true,
      "publicClient": true,
      "standardFlowEnabled": true,
      "directAccessGrantsEnabled": true,
      "redirectUris": ["http://localhost:*"],
      "defaultClientScopes": ["web-origins", "email", "openid", "profile", "seaweed-roles", "seaweed-audience"]
    },
    {
      "clientId": "client-app-1",
      "enabled": true,
      "secret": "${client_app_1_secret}",
      "serviceAccountsEnabled": true,
      "publicClient": false,
      "defaultClientScopes": ["email", "openid", "seaweed-roles", "seaweed-audience"]
    },
    {
      "clientId": "client-app-2",
      "enabled": true,
      "secret": "${client_app_2_secret}",
      "serviceAccountsEnabled": true,
      "publicClient": false,
      "defaultClientScopes": ["email", "openid", "seaweed-roles", "seaweed-audience"]
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
  "users": [
    {
      "username": "service-account-client-app-1",
      "enabled": true,
      "serviceAccountClientId": "client-app-1",
      "realmRoles": ["customer-1"]
    },
    {
      "username": "service-account-client-app-2",
      "enabled": true,
      "serviceAccountClientId": "client-app-2",
      "realmRoles": ["customer-2"]
    },
    {
      "username": "${test_user_username}",
      "enabled": true,
      "email": "${test_user_email}",
      "emailVerified": true,
      "firstName": "Test",
      "lastName": "User",
      "credentials": [{ "type": "password", "value": "${test_user_password}", "temporary": false }],
      "realmRoles": ["customer-2"]
    }
  ]
}
