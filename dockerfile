FROM ubuntu:18.04 
MAINTAINER juca <juca@juan-carlos.info>

ENV APP_NAME="tilemill"

RUN     export DEBIAN_FRONTEND=noninteractive \
    &&  apt-get update -y \
    &&  apt-get install -y --no-install-recommends apt-utils   \
    &&  apt-get install -y locales && locale-gen en_US.UTF-8   \
    &&  apt-get install -y curl \
    &&  curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    &&  apt-get update -y                        \
    &&  apt-get install -y nodejs git gnupg2 wget postgresql postgresql-contrib build-essential python-dev protobuf-compiler libprotobuf-dev libtokyocabinet-dev python-psycopg2 libgeos-c1v5 python-pip postgis unzip \
    &&  mkdir /opt/tilemill /root/Documents      \
    &&  cd /opt/tilemill                         \
    &&  git clone https://github.com/tilemill-project/tilemill.git \
    &&  cd tilemill       \
    &&  npm install       \
    &&  npm cache clean --force   \
    &&  apt-get clean     \
    &&  apt-get update 

RUN wget -O polygonscomplete.zip https://osmdata.openstreetmap.de/download/simplified-land-polygons-complete-3857.zip && unzip polygonscomplete.zip
RUN wget -O polyongssplit.zip https://osmdata.openstreetmap.de/download/land-polygons-split-3857.zip && unzip polyongssplit.zip
RUN wget -O populated.zip https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip && unzip populated.zip

RUN pip install imposm

RUN wget -O master.zip https://github.com/mapbox/osm-bright/zipball/master \
      && unzip master.zip

COPY run_tilemill.sh /opt/tilemill/run_tilemill.sh

EXPOSE 20008
EXPOSE 20009

# VOLUME /root/Documents

WORKDIR /opt/tilemill

COPY pg_hba.conf /etc/postgresql/10/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/10/main/pg_hba.conf && chmod 644 /etc/postgresql/10/main/pg_hba.conf
RUN /etc/init.d/postgresql restart

COPY importdatabase.sh /opt/tilemill/importdatabase.sh
RUN chmod u+x /opt/tilemill/importdatabase.sh

RUN mv /mapbox-osm-bright-* /mapbox-osm-bright
COPY configure.py /mapbox-osm-bright/configure.py
COPY osm-bright.imposm.mml /mapbox-osm-bright/osm-bright/osm-bright.imposm.mml
#WORKDIR /opt/tilemill/tilemill
#RUn ./index.js
WORKDIR /mapbox-osm-bright/
RUN mkdir -pv ~/Documents/MapBox/project
RUN find / -type d -name project
RUN ./make.py

RUN mkdir /mapbox-osm-bright/shp
RUN mv /simplified-land-polygons-complete-3857 /mapbox-osm-bright/shp/
RUN mv /land-polygons-split-3857/ /mapbox-osm-bright/shp/
RUN mv /ne_10m_populated_places.* /mapbox-osm-bright/shp/

RUN chmod u+x /opt/tilemill/run_tilemill.sh

# CMD [ "/bin/bash", "/opt/tilemill/run_tilemill.sh" ]
