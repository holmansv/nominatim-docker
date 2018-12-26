#!/bin/sh
BACKUPFILE=$1 ; shift

if [ "$BACKUPFILE" = "" ] ; then
  echo "[FATAL] No backup file specified (first argument empty)."
  exit 1
fi

echo "[INFO] Starting restoration of postgres database from file '$BACKUPFILE'. This could take a while..."

sudo -u postgres -i psql --file=$BACKUPFILE postgres

echo "[INFO] Finished restoring postgres database."
