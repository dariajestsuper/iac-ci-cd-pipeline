#!/bin/bash

terraform_dir=../terraform

echo "[INFO] Applying Terraform configuration."
echo "[INFO] Services that will be provisioned:"
echo "- AWS Lambda"
echo "- Amazon API Gateway"
echo "- Amazon DynamoDB"

cd $terraform_dir || { echo "[ERROR] Terraform directory not found!"; exit 1; }

tflocal init
tflocal fmt
tflocal validate
tflocal apply -auto-approve

echo "[INFO] Terraform configuration applied successfully."
