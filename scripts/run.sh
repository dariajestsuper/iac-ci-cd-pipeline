#!/bin/bash

compose_dir=../

echo "[INFO] Starting LocalStack container."
docker compose -f $compose_dir/compose.yml up -d
echo "[INFO] LocalStack container started."

chmod a+x apply_terraform_config.sh
sh ./apply_terraform_config.sh