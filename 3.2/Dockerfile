FROM ubuntu:xenial AS buildimg

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get -y update -qq 
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get install -y git build-essential cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev \
    libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
    postgresql-server-dev-9.5 python-pip libboost-python-dev php php-pgsql php-pear php-db

WORKDIR /app

# compile nominatim 
ENV NOMINATIM_VERSION v3.2.0
RUN git clone --recursive https://github.com/openstreetmap/Nominatim src

WORKDIR /app/src
RUN git checkout tags/$NOMINATIM_VERSION && git submodule update --recursive --init 
RUN mkdir build && cd build && cmake .. && make



FROM ubuntu:xenial AS runtime

WORKDIR /app/src
COPY --from=buildimg /app/src . 

RUN apt-get -y update -qq 
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get install -y postgresql-9.5-postgis-2.2 postgresql-contrib-9.5 \
    apache2 php php-pgsql libapache2-mod-php php-pear php-db \
    php-intl curl sudo \
    python-gdal unzip \
    osmosis

# Load initial data
RUN curl http://www.nominatim.org/data/country_grid.sql.gz > /app/src/data/country_osm_grid.sql.gz
RUN curl https://nominatim.org/data/tiger2017-nominatim-preprocessed.tar.gz > /app/src/data/tiger.tgz 
RUN tar -xzf /app/src/data/tiger.tgz -C /app/src/data/

# Correct the Error: could not open temporary statistics file "/var/run/postgresql/9.5-main.pg_stat_tmp/global.tmp": No such file or directory
RUN mkdir -p /var/run/postgresql/9.5-main.pg_stat_tmp
RUN chown postgres:postgres /var/run/postgresql/9.5-main.pg_stat_tmp -R

# Apache configure
COPY local.php /app/src/build/settings/local.php
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf
COPY mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# Postgres 9.5 config settings
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN sed -i -e"s/^max_connections = 100.*$/max_connections = 1100/" /etc/postgresql/9.5/main/postgresql.conf
##### write-ahead log settings:
# https://www.postgresql.org/docs/9.5/static/runtime-config-wal.html
##### resource consumption: 
# https://www.postgresql.org/docs/9.5/static/runtime-config-resource.html
RUN echo $"\n\
listen_addresses='*' \n\
max_wal_size = 100GB \n\
min_wal_size = 1GB \n\
synchronous_commit = off \n\
checkpoint_timeout = 1h \n\
checkpoint_completion_target = 0.9 \n\
maintenance_work_mem = 15GB \n\
work_mem = 100MB \n\
shared_buffers = 4GB \n\
effective_cache_size = 48GB \n\
" >> /etc/postgresql/9.5/main/postgresql.conf

EXPOSE 5432
EXPOSE 8080

COPY start.sh /app/start.sh
COPY startapache.sh /app/startapache.sh
COPY startpostgres.sh /app/startpostgres.sh
COPY init.sh /app/init.sh


