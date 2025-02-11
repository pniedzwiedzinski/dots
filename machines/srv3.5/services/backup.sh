#!/bin/bash

BACKUP_DIR=/recovery/backups
LOG_DIR=/recovery/logs
TARGET="backup$(date +%Y-%m-%d_%H-%M-%S)"

exec &>"$LOG_DIR/$TARGET.log"
mkdir $BACKUP_DIR/$TARGET
tar --exclude='/recovery' --exclude='/proc' --exclude='/dev'--exclude='/snap' --exclude='/sbin' --exclude='/run' --exclude='/lib' --exclude='lib32' --exclude='/sys' --exclude='/tmp' --exclude='/var/lib' --exclude='/boot' -cvpPzf "$BACKUP_DIR/$TARGET/$TARGET.taz.gz" /*
onedrive -v --synchronize --upload-only --no-remote-delete --syncdir="$BACKUP_DIR/$TARGET"
rm -rf "$BACKUP_DIR/$TARGET"
