#!/usr/bin/env bash
set -euo pipefail

KEYCLOAK_DOMAIN="${KEYCLOAK_DOMAIN:-keycloak.ionos.meshcloud.io}"
SEAWEEDFS_DOMAIN="${SEAWEEDFS_DOMAIN:-seaweedfs.ionos.meshcloud.io}"

KEYCLOAK_URL="https://${KEYCLOAK_DOMAIN}"
S3_ENDPOINT="https://${SEAWEEDFS_DOMAIN}"

CLIENT_SECRET=$(terraform output -raw keycloak_client_secret)
echo "Got client secret"

TEST_PASSWORD=$(terraform output -raw keycloak_test_user_password)

ID_TOKEN=$(curl -s -X POST \
  "${KEYCLOAK_URL}/realms/seaweedfs/protocol/openid-connect/token" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "client_id=seaweedfs-client" \
  --data-urlencode "client_secret=$CLIENT_SECRET" \
  --data-urlencode "username=testuser" \
  --data-urlencode "password=$TEST_PASSWORD" \
  --data-urlencode "scope=openid" | jq -r '.id_token')

if [ "$ID_TOKEN" = "null" ] || [ -z "$ID_TOKEN" ]; then
  echo "ERROR: Failed to get ID token"
  exit 1
fi
echo "Got ID token"

STS_RESULT=$(curl -s "$S3_ENDPOINT" \
  --data-urlencode "Action=AssumeRoleWithWebIdentity" \
  --data-urlencode "WebIdentityToken=$ID_TOKEN" \
  --data-urlencode "RoleArn=arn:aws:iam::role/S3WriteRole" \
  --data-urlencode "RoleSessionName=testuser-session" \
  --data-urlencode "Version=2011-06-15")

export AWS_ACCESS_KEY_ID=$(echo "$STS_RESULT" | xmllint --xpath '//*[local-name()="AccessKeyId"]/text()' -)
export AWS_SECRET_ACCESS_KEY=$(echo "$STS_RESULT" | xmllint --xpath '//*[local-name()="SecretAccessKey"]/text()' -)
export AWS_SESSION_TOKEN=$(echo "$STS_RESULT" | xmllint --xpath '//*[local-name()="SessionToken"]/text()' -)
echo "Got STS credentials (AccessKeyId: $AWS_ACCESS_KEY_ID)"

echo ""
echo "=== List buckets ==="
aws --endpoint-url "$S3_ENDPOINT" s3 ls

BUCKET="test-bucket-$(date +%s)"
echo ""
echo "=== Create bucket: $BUCKET ==="
aws --endpoint-url "$S3_ENDPOINT" s3 mb "s3://$BUCKET"

echo "hello from SeaweedFS STS test" > /tmp/seaweed-test.txt
echo ""
echo "=== Upload file ==="
aws --endpoint-url "$S3_ENDPOINT" s3 cp /tmp/seaweed-test.txt "s3://$BUCKET/test.txt"

echo ""
echo "=== List bucket contents ==="
aws --endpoint-url "$S3_ENDPOINT" s3 ls "s3://$BUCKET/"

echo ""
echo "=== Download file ==="
aws --endpoint-url "$S3_ENDPOINT" s3 cp "s3://$BUCKET/test.txt" /tmp/seaweed-download.txt
echo "Downloaded content: $(cat /tmp/seaweed-download.txt)"

echo ""
echo "=== Delete file ==="
aws --endpoint-url "$S3_ENDPOINT" s3 rm "s3://$BUCKET/test.txt"

echo ""
echo "=== Delete bucket ==="
aws --endpoint-url "$S3_ENDPOINT" s3 rb "s3://$BUCKET"

echo ""
echo "All tests passed!"
