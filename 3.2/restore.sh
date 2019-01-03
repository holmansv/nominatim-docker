#!/bin/sh
BACKUPFILE=$1 ; shift

if [ "$BACKUPFILE" = "" ] ; then
  echo "[FATAL] No backup file specified (second argument empty)."
  exit 1
fi

echo "[INFO] Starting restoration of postgres database from file '$BACKUPFILE'. This could take a while..."

sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /var/lib/postgresql/9.5/main start && \
sleep 2 && \
sudo -u postgres -i psql --file=$BACKUPFILE postgres && \
sleep 2 && \
sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /var/lib/postgresql/9.5/main stop

echo "[INFO] Finished restoring postgres database."
