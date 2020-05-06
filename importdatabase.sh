#!/bin/bash

/etc/init.d/postgresql start
psql -U postgres -c "create database osm;"
psql -U postgres -d osm -f /usr/share/postgresql/10/contrib/postgis-2.4/postgis.sql
psql -U postgres -d osm -f /usr/share/postgresql/10/contrib/postgis-2.4/spatial_ref_sys.sql

imposm --connection=postgis://postgres:@localhost:5432/osm -m /mapbox-osm-bright-f1c8780/imposm-mapping.py --read --write --optimize --deploy-production-tables /data.osm.pbf