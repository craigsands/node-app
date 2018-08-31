#!/usr/bin/env bash

REPO_USER='johnmorris23'
AWS_REGION='us-east-1'
S3_BUCKET_NAME=''
LOCK_TABLE_NAME=''
REPO_PASS=''
REPO_NAME=''
REPO_EMAIL=''

# Pull the repo
git clone https://github.com/${REPO_USER}/node-app.git

# Destroy the node-app deployment (from tfstate file in s3)
cd config/node-app
terraform init \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="bucket=${S3_BUCKET_NAME}" \
  -backend-config="dynamodb_table=${LOCK_TABLE_NAME}"
terraform destroy \
  -auto-approve \
  -var "aws_region=${AWS_REGION}"

# Delete node-app deployment state from s3
aws s3 rm "s3://${S3_BUCKET_NAME}/terraform.tfstate"

# Destroy the s3 & dynamodb deployment
cd ../backend
terraform init
terraform destroy --auto-approve

# Commit the tfstate back (now containing nothing)
cd ../../  # get back to root
git add config/backend/terraform.tfstate
git \
  -c user.name="${REPO_NAME}" \
  -c user.email="${REPO_EMAIL}" \
  commit \
  -m "terraform backend destroyed in AWS"
git push "https://${REPO_USER}:${REPO_PASS}@github.com/${REPO_USER}/node-app.git master"
