#!/bin/bash
LOG_DIR="$HOME/dragon9_workspace/logs"
REPORT="$LOG_DIR/drive_audit_report.txt"
mkdir -p "$LOG_DIR"

echo "=== SECRETARY BOT DRIVE & SYSTEM AUDIT ===" > "$REPORT"
echo "Timestamp: $(date -u +"%Y-%m-%d %T UTC")" >> "$REPORT"
echo "" >> "$REPORT"

echo "--- Mounted Disks and Partitions ---" >> "$REPORT"
lsblk -f >> "$REPORT"
echo "" >> "$REPORT"

echo "--- Disk Space Usage ---" >> "$REPORT"
df -h >> "$REPORT"
echo "" >> "$REPORT"

echo "Audit complete. Report saved to $REPORT"
