#!/bin/bash
# Checks disk usage and sends SNS alert if threshold is crossed.
#

# ========== CONFIG ==========
MOUNT_POINT="/"                # Disk mount point to check
THRESHOLD=80                   # % usage threshold
SNS_TOPIC_ARN="arn:aws:sns:ap-south-1:123456789012:DiskAlerts"
AWS_REGION="ap-south-1"        # Change to your region
HOSTNAME=$(hostname)           # Server name for message
# =============================

USAGE=$(df -h "$MOUNT_POINT" | awk 'NR==2 {gsub("%","",$5); print $5}')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
  MESSAGE="⚠️ Disk Usage Alert on $HOSTNAME
Mount Point: $MOUNT_POINT
Current Usage: $USAGE%
Threshold: $THRESHOLD%

Please take action immediately."
  
  echo "$MESSAGE"
  
  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --region "$AWS_REGION" \
    --message "$MESSAGE" \
    --subject "Disk Usage Alert: $HOSTNAME"
else
  echo "✅ Disk usage is normal ($USAGE% used on $MOUNT_POINT)."
fi

