#!/bin/bash
# ==========================================================
# EC2 Start/Stop Script by Tag
# Description: Start or stop all EC2 instances with a specific tag
# Author: Praveen (DevOps Scripts Repo)
# ==========================================================

# ========== CONFIG ==========
AWS_REGION="ap-south-1"        # Change to your AWS region
# =============================

# Usage
usage() {
  echo "Usage: $0 <start|stop> <tag-key> <tag-value>"
  echo "Example: $0 start Environment Dev"
  exit 1
}

# Input validation
if [ $# -ne 3 ]; then
  usage
fi

ACTION=$1
TAG_KEY=$2
TAG_VALUE=$3

# Get instance IDs with the given tag (running or stopped)
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running,stopped" \
  --region "$AWS_REGION" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "❌ No instances found with tag $TAG_KEY=$TAG_VALUE"
  exit 1
fi

# Loop through instances
for INSTANCE_ID in $INSTANCE_IDS; do
  echo "➡️ $ACTION instance $INSTANCE_ID ..."

  if [ "$ACTION" == "start" ]; then
    aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$AWS_REGION" > /dev/null
  elif [ "$ACTION" == "stop" ]; then
    aws ec2 stop-instances --instance-ids "$INSTANCE_ID" --region "$AWS_REGION" > /dev/null
  else
    usage
  fi

  # Wait for the instance to change state
  aws ec2 wait instance-$ACTION --instance-ids "$INSTANCE_ID" --region "$AWS_REGION"

  # Get current state
  STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$AWS_REGION" \
    --query "Reservations[].Instances[].State.Name" \
    --output text)

  echo "✅ Instance $INSTANCE_ID is now $STATE"
done

