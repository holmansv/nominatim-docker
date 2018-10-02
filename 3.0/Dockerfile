FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get -y update -qq
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install dependencies (automatically removed in multi-stage build)
RUN apt-get install -y build-essential cmake g++ libboost-dev libboost-system-dev \
libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev \
libpq-dev libgeos-dev libgeos++-dev libproj-dev libbz2-dev \
postgresql-server-dev-9.5 git
# Cleanup is not necessary with multi-stage build!  these dependencies will not be copied over!

WORKDIR /app/src

# Nominatim install and build
ENV NOMINATIM_VERSION v3.0.1
RUN git clone --recursive https://github.com/openstreetmap/Nominatim .
RUN git checkout tags/$NOMINATIM_VERSION && git submodule update --recursive --init
RUN mkdir build && cd build && cmake .. && make

# RUNTIME!
FROM ubuntu:xenial

# TODO Do we want to drop the /src at this point?
WORKDIR /app/src
COPY --from=0 /app/src .

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get -y update -qq
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Load initial data
COPY country_osm_grid.sql.gz data/country_osm_grid.sql.gz
COPY data.osm.pbf data/data.osm.pbf
ADD tiger.tar.gz data/

# Runtime Dependencies
RUN apt-get install -y apache2 php php-pgsql libapache2-mod-php php-pear php-db \
php-intl python-pip libboost-python-dev gdal-bin python-gdal \
postgresql-9.5-postgis-2.2 postgresql-contrib-9.5 \
libbz2-dev libz-dev unzip sudo

# TODO Possibly Unnecessary Dependencies?
RUN apt-get install -y osmosis
RUN pip install osmium

# Cleanup runtime after dependecy install
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/* /var/tmp/*

# Apache
COPY local.php build/settings/local.php
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
RUN sed -i -e"s/^max_connections = 100.*$/max_connections = 1000/" /etc/postgresql/9.5/main/postgresql.conf

# nominatim user
# TODO Do we need the nominatim user?  This is docker...
RUN useradd nominatim && \
chown -R nominatim:nominatim /app/src

# initial state of Postgres DB
RUN service postgresql start && \
    sudo -u postgres createuser -s nominatim && \
    sudo -u postgres createuser -SDR www-data && \
    sudo -u nominatim /app/src/build/utils/setup.php --osm-file /app/src/data/data.osm.pbf --all --import-tiger-data --threads 64 && \
    sudo -u nominatim /app/src/build/utils/setup.php --create-functions --enable-diff-updates --create-partition-functions && \
    service postgresql stop

EXPOSE 5432

# TODO Is this necessary to expose in production?
# EXPOSE 8080

WORKDIR /app
COPY start.sh start.sh
CMD start.sh
