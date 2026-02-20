{
  "realm": "seaweedfs",
  "enabled": true,
  "groups": [
    {
      "name": "admins"
    },
    {
      "name": "developers"
    }
  ],
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
      "groups": [
        "developers"
      ]
    }
  ],
  "clients": [
    {
      "clientId": "seaweedfs-client",
      "name": "SeaweedFS OIDC Client",
      "secret": "${client_secret}",
      "enabled": true,
      "protocol": "openid-connect",
      "clientAuthenticatorType": "client-secret",
      "publicClient": false,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": true,
      "serviceAccountsEnabled": false,
      "standardFlowEnabled": true,
      "rootUrl": "https://${fqdn}",
      "redirectUris": [
        "https://${fqdn}/*"
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
          "name": "groups-mapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-group-membership-mapper",
          "consentRequired": false,
          "config": {
            "full.path": "false",
            "introspection.token.claim": "true",
            "multivalued": "true",
            "userinfo.token.claim": "true",
            "id.token.claim": "true",
            "access.token.claim": "true",
            "claim.name": "groups",
            "jsonType.label": "String"
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
  ]
}
