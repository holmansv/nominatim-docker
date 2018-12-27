#!/bin/sh
PGDIR=$1
if [ "$PGDIR" = "" ] ; then
  echo "[ERROR] Path to postgres data dir is empty. Cannot continue script."
  exit 1
fi

echo "[INFO] init.sh - setting up an empty postgres database ..."

mkdir -p /data/$PGDIR

chown postgres:postgres /data/$PGDIR 

export  PGDATA=/data/$PGDIR  && \
sudo -u postgres /usr/lib/postgresql/9.5/bin/initdb -D /data/$PGDIR && \
sudo -u postgres cp /etc/postgresql/9.5/main/postgresql.conf /data/$PGDIR && \
sudo -u postgres cp /etc/postgresql/9.5/main/pg_hba.conf /data/$PGDIR 

echo "[INFO] init.sh - finished setting up empty postgres database. Next step is to either run load-osm.sh , or run psql restore with a backup file."
