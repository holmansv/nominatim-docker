#!/bin/sh
PGDIR=$1 ; shift
OSMFILE=$1 ; shift
THREADS=$1 ; shift

echo "[INFO] Starting script to load osm data."

if [ "$PGDIR" = "" ] ; then
  echo "[ERROR] Postgres data directory argument is empty."
  exit 1
fi

if [ "$OSMFILE" = "" ] ; then
  echo "[ERROR] The path to the OSM file to load was empty."
  exit 1
fi

if [ "$THREADS" = "" ] ; then
  echo "[ERROR] Number of threads must be specified."
  exit 1
fi

echo "[INFO] Importing OSM data file '$OSMFILE'..."
export  PGDATA=/data/$PGDIR  && \
sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR start && \
sleep 2 && \
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
sudo -u nominatim /app/src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS && \
# sudo -u postgres psql postgres -tAc "CREATE INDEX nodes_index ON public.planet_osm_ways USING gin (nodes);"
sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR stop && \
sudo chown -R postgres:postgres /data/$PGDIR
echo "[INFO] Finished importing OSM data."

if [ -d /app/src/data/tiger ] ; then
  echo "[INFO] Found extracted Tiger data at /app/src/data/tiger; importing Tiger data ..."
  export  PGDATA=/data/$PGDIR  && \
  sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR start && \
  sleep 2 && \
  sudo -u nominatim /app/src/build/utils/setup.php --import-tiger-data && \
  sudo -u nominatim /app/src/build/utils/setup.php --create-functions --enable-diff-updates --create-partition-functions && \
  sudo -u postgres /usr/lib/postgresql/9.5/bin/pg_ctl -D /data/$PGDIR stop && \
  sudo chown -R postgres:postgres /data/$PGDIR
  echo "[INFO] Finished importing Tiger data."
else
  echo "[INFO] Tiger data not found in expected location /app/src/data/tiger ; skipped importing Tiger data." 
fi

echo "[INFO] Finished script to load osm data."
