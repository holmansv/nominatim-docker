#!/bin/sh
BACKUPFILE=$1 ; shift

if [ "$BACKUPFILE" = "" ] ; then
  echo "[FATAL] No backup file specified (first argument empty)."
  exit 1
fi

echo "[INFO] Starting restoration of postgres database. This could take a while..."

gunzip $BACKUPFILE
sudo -u postgres -i psql -f $BACKUPFILE postgres

echo "[INFO] Finished restoring postgres database."
