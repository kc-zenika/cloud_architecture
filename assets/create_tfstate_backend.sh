#!/bin/bash

set -euo pipefail

REGION="ap-southeast-1"

echo "Resolving AWS account ID..."
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="workshop-tfstate-${ACCOUNT_ID}"

if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  echo "Bucket ${BUCKET_NAME} already exists, skipping creation."
else
  echo "Creating bucket ${BUCKET_NAME}..."
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "Disabling ACLs (bucket owner enforced)..."
aws s3api put-bucket-ownership-controls \
  --bucket "$BUCKET_NAME" \
  --ownership-controls Rules='[{ObjectOwnership=BucketOwnerEnforced}]'

echo "Blocking all public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Enabling bucket versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Enabling SSE-S3 encryption with bucket key..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

echo "Tagging bucket..."
aws s3api put-bucket-tagging \
  --bucket "$BUCKET_NAME" \
  --tagging 'TagSet=[{Key=manuallyCreated,Value=true}]'

echo
echo "Done. Bucket: s3://${BUCKET_NAME} (region: ${REGION})"
echo
echo "Next step: you have to update aws/development/provider.tf"
echo
echo "-- backend block --"
echo "  replace bucket = \"workshop-tfstate-<ACCOUNT_ID>\""
echo "  with    bucket = \"workshop-tfstate-${ACCOUNT_ID}\""
echo
echo "-- locals block --"
echo "  replace account_id = \"<ACCOUNT_ID>\""
echo "  with    account_id = \"${ACCOUNT_ID}\""
