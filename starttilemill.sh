#!/bin/bash

docker run -p 20009:20009 -p 20008:20008 -e TILE_URL=localhost:20008 -ti --entrypoint=/opt/tilemill/run_tilemill.sh temp/dockertilemill