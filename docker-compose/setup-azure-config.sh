#!/bin/bash
set -e

echo "🔧 Updating Azure opkssh configuration"
echo ""

# Check if AZURE_FQDN is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <AZURE_FQDN>"
    echo ""
    echo "Example: $0 testminio.germanywestcentral.cloudapp.azure.com"
    echo ""
    echo "This script updates the opkssh configuration files for external testing"
    echo "with your Azure deployment's FQDN."
    exit 1
fi

AZURE_FQDN="$1"
HTTPS_PORT="${2:-8444}"

echo "📝 Updating configuration for:"
echo "   FQDN: $AZURE_FQDN"
echo "   Port: $HTTPS_PORT"
echo ""

# Update providers file
cat > opk-providers-azure/providers <<EOF
https://${AZURE_FQDN}:${HTTPS_PORT}/realms/minio_realm opkssh-client 24h
EOF

# Update auth_id file
cat > opk-auth_id-azure/auth_id <<EOF
testuser test@test.com https://${AZURE_FQDN}:${HTTPS_PORT}/realms/minio_realm
EOF

echo "✅ Updated files:"
echo "   - opk-providers-azure/providers"
echo "   - opk-auth_id-azure/auth_id"
echo ""
echo "📋 Next steps:"
echo "1. Copy your Azure certificate to this directory as 'minio-cert.pem'"
echo ""
echo "2. Start the external test SSH server:"
echo "   docker-compose -f docker-compose.external-test.yml up -d"
echo ""
echo "3. Login with opkssh:"
echo "   opkssh login --provider=\"https://${AZURE_FQDN}:${HTTPS_PORT}/realms/minio_realm,opkssh-client\""
echo ""
echo "4. SSH to test server:"
echo "   ssh -p 2223 testuser@localhost"
echo ""
