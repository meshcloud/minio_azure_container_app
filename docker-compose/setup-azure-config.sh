#!/bin/bash
set -e

echo "Updating Azure opkssh configuration"
echo ""

if [ -z "$1" ]; then
    echo "Usage: $0 <KEYCLOAK_URL>"
    echo ""
    echo "Example: $0 https://auth.example.com"
    echo ""
    echo "This script updates the opkssh configuration files for external testing"
    echo "with your deployed Keycloak URL."
    exit 1
fi

KEYCLOAK_URL="$1"

echo "Updating configuration for:"
echo "   Keycloak URL: $KEYCLOAK_URL"
echo ""

cat > opk-providers-azure/providers <<EOF
${KEYCLOAK_URL}/realms/seaweedfs opkssh-client 24h
EOF

cat > opk-auth_id-azure/auth_id <<EOF
testuser test@test.com ${KEYCLOAK_URL}/realms/seaweedfs
EOF

echo "Updated files:"
echo "   - opk-providers-azure/providers"
echo "   - opk-auth_id-azure/auth_id"
echo ""
echo "Next steps:"
echo "1. Start the external test SSH server:"
echo "   docker-compose -f docker-compose.external-test.yml up -d"
echo ""
echo "2. Login with opkssh:"
echo "   opkssh login --provider=\"${KEYCLOAK_URL}/realms/seaweedfs,opkssh-client\""
echo ""
echo "3. SSH to test server:"
echo "   ssh -p 2223 testuser@localhost"
echo ""
