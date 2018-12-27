# Nominatim Docker (Nominatim version 3.2)

## Building The Docker Image
  ```
  docker build -t nominatim .
  ```

## Building A Copy Of The Postgres Database
1. Copy `<country>.osm.pbf` to a local directory (i.e. /srv/nominatim)

1. Initialize Nominatim Database
   ```
   docker run -t -v /srv/nominatim:/data <imageId> sh /app/init.sh postgresdata
   ```

1. Populate the db with a transformation of the OSM data into Nominatim format:   
   ```
   docker run -t -v /srv/nominatim:/data <imageId> sh /app/load-osm.sh postgresdata /data/monaco-latest.osm.pbf 4
   ```
   Where 4 is the number of threads to use during import. In general the import of data in postgres is a very time consuming
   process that may take hours or days. If you run this process on a multiprocessor system make sure that it makes the best use
   of it. You can delete the `/srv/nominatim/<country>.osm.pbf` once the import is finished.

1. Export an archive copy of the database from Postgres:  
   ```
   docker run -t -v /srv/nominatim:/data 46176800190d sh /app/backup.sh /srv/tmp
   ```
   This command deposits a file named `pgdumpall.sql` in the location specified to the script (in above case, `/srv/tmp`).  


## Restoring The Postgres Database


## Boot Up the Nominatim Server
1. After the import is finished the `/srv/nominatim/postgresdata` folder will contain the full postgress binaries of
   a postgis/nominatim database. The easiest way to start the nominatim as a single node is the following:
   ```
   docker run --restart=always -p 5432:5432 -p 8080:8080 -d -v /srv/nominatim/postgresdata:/var/lib/postgresql/9.5/main <ImageId> sh /app/start.sh
   ```

## Advanced Configuration
If necessary you can split the osm installation into a database and restservice layer.  

   In order to set the  nominatib-db only node:

   ```
   docker run --restart=always -p 5432:5432 -d -v /home/me/nominatimdata/postgresdata:/var/lib/postgresql/9.5/main nominatim sh /app/startpostgres.sh
   ```
   After doing this create the /home/me/nominatimdata/conf folder and copy there the docker/local.php file. Then uncomment the following line:

   ```
   @define('CONST_Database_DSN', 'pgsql://nominatim:password1234@192.168.1.128:6432/nominatim'); // <driver>://<username>:<password>@<host>:<port>/<database>
   ```

   You can start the  nominatib-rest only node with the following command:

   ```
   docker run --restart=always -p 7070:8080 -d -v /home/me/nominatimdata/conf:/data nominatim sh /app/startapache.sh
   ```

6. Configure incremental update. By default CONST_Replication_Url configured for Monaco.
If you want a different update source, you will need to declare `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/openstreetmap/Nominatim/blob/master/docs/Import-and-Update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany-updates');
  ```

  Now you will have a fully functioning nominatim instance available at : [http://localhost:7070/](http://localhost:7070). Unlike the previous versions
  this one does not store data in the docker context and this results to a much slimmer docker image.


# Update

Full documentation for Nominatim update available [here](https://github.com/openstreetmap/Nominatim/blob/master/docs/Import-and-Update.md#updates). For a list of other methods see the output of:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --help
  ```

The following command will keep your database constantly up to date:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --import-osmosis-all
  ```
If you have imported multiple country extracts and want to keep them
up-to-date, have a look at the script in
[issue #60](https://github.com/openstreetmap/Nominatim/issues/60).
