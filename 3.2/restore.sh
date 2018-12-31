#!/bin/sh
PGDIR=$1 ; shift
BACKUPFILE=$1 ; shift

if [ "$PGDIR" = "" ] ; then
  echo "[FATAL] No postgres data directory specified (first argument empty). "
  exit 1
fi

if [ "$BACKUPFILE" = "" ] ; then
  echo "[FATAL] No backup file specified (second argument empty)."
  exit 1
fi

echo "[INFO] Starting restoration of postgres database from file '$BACKUPFILE'. This could take a while..."

sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR start && \
sleep 3 && \
sudo -u postgres -i psql --file=$BACKUPFILE postgres && \
sleep 2 && \
sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR stop

echo "[INFO] Finished restoring postgres database."
