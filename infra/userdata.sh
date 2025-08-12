#!/bin/bash
set -eux
dnf update -y || yum update -y || true
# Amazon Linux 2023 uses dnf; fall back for safety
dnf install -y nginx || yum install -y nginx
echo "<h1>${PROJECT_NAME} is up</h1>" > /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
