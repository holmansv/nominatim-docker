#!/bin/sh
PGDIR=$1 ; shift
DESTDIR=$1 ; shift

if [ "$PGDIR" = "" ] ; then
  echo "[FATAL] Postgres directory was not specified (empty first argument)."
  exit 1
fi

if [ "$DESTDIR" = "" ] ; then
  echo "[FATAL] Destination directory was not specified (empty second argument)."
  exit 1
fi

echo "[INFO] Starting backup of postgres database. This could take a while..."

sudo -u postgres -i pg_dumpall --file=nominatim_backup
cd /var/lib/postgresql/
sudo gzip nominatim_backup 
mv nominatim_backup.gz $DESTDIR/nominatim_backup.gz

echo "[INFO] Finished backup of postgres database."
