#!/bin/bash
# ==========================================================
# Log Rotation Script
# Description: Rotate logs in a directory, compress, and keep last N files
# Author: Praveen (DevOps Scripts Repo)
# ==========================================================

# ========== CONFIG ==========
LOG_DIR="/var/log/myapp"       # Directory containing logs
RETENTION=7                    # Number of rotated logs to keep
DATE=$(date +%Y-%m-%d)
# =============================

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
  echo "❌ Log directory $LOG_DIR does not exist."
  exit 1
fi

echo "📁 Rotating logs in $LOG_DIR ..."

# Loop through all .log files
for LOG_FILE in "$LOG_DIR"/*.log; do
  [ -e "$LOG_FILE" ] || continue  # Skip if no log files

  BASENAME=$(basename "$LOG_FILE")
  ROTATED_FILE="$LOG_DIR/${BASENAME%.*}-$DATE.log.gz"

  echo "➡️ Rotating $BASENAME -> $(basename $ROTATED_FILE)"
  
  # Compress the current log
  gzip -c "$LOG_FILE" > "$ROTATED_FILE"

  # Clear the original log
  > "$LOG_FILE"
done

# Cleanup old rotated logs
echo "🧹 Cleaning up logs older than $RETENTION days..."
find "$LOG_DIR" -name "*.log.gz" -type f -mtime +$RETENTION -exec rm -f {} \;

echo "✅ Log rotation completed."

