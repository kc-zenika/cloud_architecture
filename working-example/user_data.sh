#!/bin/bash
# 1. Update and install Nginx
dnf update -y
dnf install -y nginx

# 2. Start Nginx
systemctl start nginx
systemctl enable nginx

# 3. Pull the index.html from your S3 bucket
# Note: This requires an IAM Instance Profile attached to the EC2
aws s3 cp s3://daas-211945238520/index.html /usr/share/nginx/html/index.html

# 4. Replace INSTANCE_ID_SED with actual instance ID (IMDSv2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/INSTANCE_ID_SED/$INSTANCE_ID/g" /usr/share/nginx/html/index.html

# 5. Set correct permissions
chmod 644 /usr/share/nginx/html/index.html
