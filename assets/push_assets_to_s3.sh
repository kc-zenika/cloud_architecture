#!/bin/bash

# TODO incomplete!!!
# to see how to build locally better
set -euo pipefail

REGION="ap-southeast-1"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <account-id>"
  exit 1
fi

ACCOUNT_ID="$1"
BUCKET_NAME="workshop-part2-app-${ACCOUNT_ID}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_NAME="server"
S3_KEY="app/server"

echo "Building ${BINARY_NAME} for linux/amd64..."
(cd "$SCRIPT_DIR" && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o "$BINARY_NAME" .)

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
aws s3 cp "${SCRIPT_DIR}/${BINARY_NAME}" "s3://${BUCKET_NAME}/${S3_KEY}"

echo "Done. s3://${BUCKET_NAME}/${S3_KEY}"
