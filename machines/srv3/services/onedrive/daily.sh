#!/bin/sh

# BACKUP_DIR=/tmp/backups
# TARGET="backup_$(date +%Y-%m-%d_%H-%M-%S)"
# mkdir "$BACKUP_DIR/$TARGET"
# tar --exclude='/persist/backups' -cvpPzf "$BACKUP_DIR/$TARGET/$TARGET.taz.gz" /persist
# onedrive -v --synchronize --upload-only --no-remote-delete --syncdir="$BACKUP_DIR/$TARGET"

onedrive -v --synchronize --upload-only --no-remote-delete --syncdir="/persist"
#rm -rf "$BACKUP_DIR/$TARGET"
