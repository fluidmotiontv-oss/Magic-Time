#!/bin/bash
set -e

REMOTE="deskD9"
BACKUP_ROOT="dragon9_backups"

echo "=== Dragon 9 Comprehensive Drive & Document Backup ==="

# 1. Verify rclone remote
if ! rclone listremotes | grep -q "^${REMOTE}:"; then
    echo "[!] Error: rclone remote '${REMOTE}:' not found."
        exit 1
        fi
        echo "[+] Remote '${REMOTE}:' verified."

        # 2. Define document file types to target
        DOC_INCLUDE="*.{pdf,doc,docx,txt,odt,rtf,xls,xlsx,csv,md,epub}"

        # 3. Backup Home Directory (/home/tim) - skipping heavy caches/node_modules
        echo "[*] Backing up /home/tim documents..."
        rclone copy /home/tim ${REMOTE}:${BACKUP_ROOT}/home_tim \
            --include "$DOC_INCLUDE" \
                --exclude "node_modules/**" \
                    --exclude ".cache/**" \
                        --exclude ".npm/**" \
                            --exclude ".local/share/**" \
                                --verbose --create-empty-src-dirs

                                # 4. Backup existing media mounts (e.g., /media/single_terror_bite)
                                if [ -d "/media" ]; then
                                    for media_dir in /media/*; do
                                            if [ -d "$media_dir" ]; then
                                                        dir_name=$(basename "$media_dir")
                                                                    echo "[*] Backing up media mount: $dir_name..."
                                                                                rclone copy "$media_dir" "${REMOTE}:${BACKUP_ROOT}/media_$dir_name" \
                                                                                                --include "$DOC_INCLUDE" \
                                                                                                                --exclude "node_modules/**" \
                                                                                                                                --exclude "\$RECYCLE.BIN/**" \
                                                                                                                                                --exclude "System Volume Information/**" \
                                                                                                                                                                --verbose --create-empty-src-dirs
                                                                                                                                                                        fi
                                                                                                                                                                            done
                                                                                                                                                                            fi

                                                                                                                                                                            echo "=== Backup Complete! All documents successfully uploaded to Google Drive (${REMOTE}:${BACKUP_ROOT}/) ==="
