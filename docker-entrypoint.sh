#!/bin/bash

# Wait for Caddy CA certificate and install it
echo "Waiting for Caddy CA certificate..."
for i in {1..30}; do
    if [ -f /caddy-data/caddy/pki/authorities/local/root.crt ]; then
        cp /caddy-data/caddy/pki/authorities/local/root.crt /usr/local/share/ca-certificates/caddy-root.crt
        update-ca-certificates
        echo "Caddy CA certificate installed"
        break
    fi
    sleep 1
done

# Start socat to proxy localhost:8443 to coraza-waf:8443
socat TCP-LISTEN:8443,bind=127.0.0.1,fork,reuseaddr TCP:coraza-waf:8443 &

# Start SSH daemon
exec /usr/sbin/sshd -D -p 2222
