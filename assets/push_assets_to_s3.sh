#!/bin/bash
set -euo pipefail

REGION="ap-southeast-1"
GO_VERSION="1.26"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/app"
BINARY_NAME="demo-server"
S3_KEY="app/demo-server"

# Build inside a Docker container
echo "Building ${BINARY_NAME} for linux/amd64 via Docker..."
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e GOOS=linux \
  -e GOARCH=amd64 \
  -e CGO_ENABLED=0 \
  -v "${APP_DIR}:/app" \
  -w /app \
  "golang:${GO_VERSION}" \
  go build -o "$BINARY_NAME" .

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="workshop-part2-app-${ACCOUNT_ID}"

# Create bucket to store assets
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Bucket ${BUCKET_NAME} already exists, skipping creation."
else
  echo "Creating bucket ${BUCKET_NAME}..."
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
      "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  echo "Bucket created."
fi

echo "Uploading ${BINARY_NAME} to s3://${BUCKET_NAME}/${S3_KEY}..."
aws s3 cp "${APP_DIR}/${BINARY_NAME}" "s3://${BUCKET_NAME}/${S3_KEY}"

echo "Done. s3://${BUCKET_NAME}/${S3_KEY}"
