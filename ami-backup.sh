#!/bin/bash
# Simple AMI Backup Script
# Usage: ./ami-backup.sh <instance-id>

INSTANCE_ID=$1
DATE=$(date +%Y-%m-%d)
REGION="us-east-1"

if [ -z "$INSTANCE_ID" ]; then
  echo "Usage: $0 <instance-id>"
  exit 1
fi

AMI_NAME="backup-${INSTANCE_ID}-${DATE}"

echo "Creating AMI for $INSTANCE_ID ..."
AMI_ID=$(aws ec2 create-image \
  --instance-id "$INSTANCE_ID" \
  --name "$AMI_NAME" \
  --no-reboot \
  --region "$REGION" \
  --query 'ImageId' \
  --output text)

echo "Backup created: $AMI_ID"

