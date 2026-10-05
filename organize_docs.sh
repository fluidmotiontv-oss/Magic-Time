#!/bin/bash
# Secretary Bot Document Consolidation Script
DOC_DIR="$HOME/dragon9_workspace/documents"
LOG_FILE="$HOME/dragon9_workspace/logs/document_audit.log"

mkdir -p "$DOC_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARY BOT] Starting document consolidation..." > "$LOG_FILE"

# Find and copy common document types from the home directory into the workspace documents folder
find ~ -maxdepth 3 \( -name "*.txt" -o -name "*.pdf" -o -name "*.md" -o -name "*.doc" -o -name "*.docx" -o -name "*.odt" \) \
  ! -path "*/.*" ! -path "*/dragon9_workspace/documents*" 2>/dev/null | while read -r file; do
    cp -n "$file" "$DOC_DIR/"
    echo "Consolidated: $file" >> "$LOG_FILE"
    echo "Copied: $file"
done

echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARY BOT] Document consolidation complete. Saved to $DOC_DIR" >> "$LOG_FILE"
echo "Documents successfully gathered into $DOC_DIR"
