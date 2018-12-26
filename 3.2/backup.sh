#!/bin/sh
DESTDIR=$1 ; shift

if [ "$DESTDIR" = "" ] ; then
  echo "[FATAL] Destination directory was not specified (empty first argument)."
  exit 1
fi

FILENAME=pgdumpall.sql

echo "[INFO] Starting backup of postgres database. This could take a while..."

sudo -u postgres -i pg_dumpall --file=$FILENAME 
sudo mv /var/lib/postgresql/9.5/main/$FILENAME $DESTDIR/$FILENAME

echo "[INFO] Finished backup of postgres database. Backup is located at $DESTDIR/$FILENAME"
