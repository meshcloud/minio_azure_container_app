#!/bin/bash
set -e

echo "Setting up opkssh test environment"
echo ""

echo "Building SSH server image..."
docker-compose build ssh-server

echo "Starting SSH server..."
docker-compose up -d

echo "Waiting for container to start..."
sleep 3

echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Install opkssh:"
echo "   macOS:  brew tap openpubkey/opkssh && brew install opkssh"
echo "   Linux:  curl -L https://github.com/openpubkey/opkssh/releases/latest/download/opkssh-linux-amd64 -o opkssh && chmod +x opkssh && sudo mv opkssh /usr/local/bin/"
echo ""
echo "2. Login with opkssh:"
echo "   opkssh login --provider=\"http://auth.localhost/realms/seaweedfs,opkssh-client\""
echo ""
echo "3. SSH to test server:"
echo "   ssh -p 2222 testuser@localhost"
echo ""
echo "Prerequisites:"
echo "   Keycloak must be running in k8s (terraform apply) at http://auth.localhost"
echo ""
echo "Default credentials:"
echo "   Keycloak: admin / admin"
echo "   Test user: test@test.com / test"
echo ""
