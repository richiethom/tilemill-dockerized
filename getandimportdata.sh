#!/bin/bash

# wget -O /tmp/data.osm.pbf https://download.geofabrik.de/europe/isle-of-man-latest.osm.pbf

wget -O /tmp/data.osm.pbf $1

docker run -v /tmp/data.osm.pbf:/data.osm.pbf -p 20009:20009 -p 20008:20008 -e TILE_URL=localhost:20008 --name dockertilemill tilemill3 /opt/tilemill/importdatabase.sh

rm /tmp/data.osm.pbf