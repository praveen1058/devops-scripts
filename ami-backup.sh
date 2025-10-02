#!/bin/bash
# ==========================================================
# AMI Backup Script with Retention
# Description: Create AMI backup of an EC2 instance (by tag)
#              and delete old backups after X days.
# Author: Praveen (DevOps Scripts Repo)
# ==========================================================

# Config
REGION="us-east-1"
RETENTION_DAYS=7   # keep backups for 7 days

# Usage function
usage() {
  echo "Usage: $0 <tag-key> <tag-value>"
  echo "Example: $0 Name MyServer"
  exit 1
}

# Input validation
if [ $# -ne 2 ]; then
  usage
fi

TAG_KEY=$1
TAG_VALUE=$2
DATE=$(date +%Y-%m-%d)

# Find instance by tag
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running" \
  --region "$REGION" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

if [ -z "$INSTANCE_ID" ]; then
  echo "❌ No instance found with tag $TAG_KEY=$TAG_VALUE"
  exit 1
fi

# Create AMI
AMI_NAME="backup-${TAG_VALUE}-${DATE}"
echo "➡️ Creating AMI for $INSTANCE_ID ($TAG_KEY=$TAG_VALUE) ..."
AMI_ID=$(aws ec2 create-image \
  --instance-id "$INSTANCE_ID" \
  --name "$AMI_NAME" \
  --description "Automated backup for $TAG_VALUE on $DATE" \
  --no-reboot \
  --region "$REGION" \
  --query 'ImageId' \
  --output text)

echo "✅ Backup created: $AMI_ID"

# Tag AMI
aws ec2 create-tags \
  --resources "$AMI_ID" \
  --tags Key=Backup,Value=$TAG_VALUE \
  --region "$REGION"

echo "🏷️ Tagged AMI with Backup=$TAG_VALUE"

# Cleanup old AMIs
echo "🧹 Looking for AMIs older than $RETENTION_DAYS days..."
OLD_AMIS=$(aws ec2 describe-images \
  --owners self \
  --filters "Name=tag:Backup,Values=$TAG_VALUE" \
  --region "$REGION" \
  --query "Images[?CreationDate<='$(date -d "-$RETENTION_DAYS days" --utc +%Y-%m-%dT%H:%M:%S)'].ImageId" \
  --output text)

if [ -n "$OLD_AMIS" ]; then
  for AMI in $OLD_AMIS; do
    echo "⚠️ Deregistering old AMI: $AMI"
    aws ec2 deregister-image --image-id "$AMI" --region "$REGION"
  done
else
  echo "✅ No old AMIs found for cleanup."
fi

echo "🎉 Backup + cleanup process completed for $TAG_VALUE"
