#!/bin/bash

set -euo pipefail

REGION="ap-southeast-1"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <account-id>"
  exit 1
fi

ACCOUNT_ID="$1"
BUCKET_NAME="daas-${ACCOUNT_ID}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_HTML="${SCRIPT_DIR}/index.html"

if [[ ! -f "$INDEX_HTML" ]]; then
  echo "Error: index.html not found at ${INDEX_HTML}"
  exit 1
fi

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

echo "Uploading index.html to s3://${BUCKET_NAME}/..."
aws s3 cp "$INDEX_HTML" "s3://${BUCKET_NAME}/index.html"

echo "Done. s3://${BUCKET_NAME}/index.html"