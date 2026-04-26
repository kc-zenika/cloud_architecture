#!/bin/bash
# 1. Update and install Nginx
dnf update -y
dnf install -y nginx

# 2. Start Nginx
systemctl start nginx
systemctl enable nginx

# 3. Pull the index.html from your S3 bucket
# Note: This requires an IAM Instance Profile attached to the EC2
aws s3 cp s3://daas-787525931078/index.html /usr/share/nginx/html/index.html

# 4. Set correct permissions
chmod 644 /usr/share/nginx/html/index.html