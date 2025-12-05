#!/bin/bash
set -e

echo "🚀 Setting up local MinIO + Keycloak + opkssh environment"
echo ""

# Step 1: Build the Caddy WAF image
echo "📦 Building Caddy WAF image..."
cd ..
docker build -t coraza-waf-local:latest -f Dockerfile .
cd docker-compose

# Step 2: Start services to generate Caddy certificate
echo "🔐 Starting services to generate Caddy CA certificate..."
docker-compose up -d coraza-waf

# Step 3: Wait for Caddy to generate certificates
echo "⏳ Waiting for Caddy to generate certificates..."
for i in {1..30}; do
    if docker exec coraza-waf test -f /data/caddy/pki/authorities/local/root.crt 2>/dev/null; then
        echo "✅ Caddy CA certificate found!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Timeout waiting for Caddy certificate"
        exit 1
    fi
    sleep 1
done

# Step 4: Extract Caddy CA certificate
echo "📄 Extracting Caddy CA certificate..."
docker cp coraza-waf:/data/caddy/pki/authorities/local/root.crt ./caddy-root-ca.crt
chmod 644 caddy-root-ca.crt

# Step 5: Trust the certificate on macOS (requires sudo password)
echo ""
echo "🔒 Installing Caddy CA certificate to system trust store..."
echo "   (This requires your sudo password)"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./caddy-root-ca.crt
    echo "✅ Certificate trusted on macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo cp ./caddy-root-ca.crt /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    echo "✅ Certificate trusted on Linux"
else
    echo "⚠️  Please manually trust the certificate at: $(pwd)/caddy-root-ca.crt"
fi

# Step 6: Start all services
echo ""
echo "🚢 Starting all services..."
docker-compose up -d

# Step 7: Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Step 8: Check service health
echo ""
echo "🏥 Service Status:"
docker-compose ps

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Install opkssh:"
echo "   macOS:  brew tap openpubkey/opkssh && brew install opkssh"
echo "   Linux:  curl -L https://github.com/openpubkey/opkssh/releases/latest/download/opkssh-linux-amd64 -o opkssh && chmod +x opkssh && sudo mv opkssh /usr/local/bin/"
echo ""
echo "2. Login with opkssh:"
echo "   opkssh login --provider=\"https://localhost:8443/realms/minio_realm,opkssh-client\""
echo ""
echo "3. SSH to test server:"
echo "   ssh -p 2222 testuser@localhost"
echo ""
echo "🌐 Service URLs:"
echo "   MinIO Console:  http://localhost:8080"
echo "   Keycloak:       http://localhost:8082"
echo "   Keycloak HTTPS: https://localhost:8443"
echo ""
echo "🔑 Default credentials:"
echo "   Keycloak: admin / admin"
echo "   Test user: test@test.com / test"
echo "   MinIO: minioadmin / minioadmin"
echo ""
