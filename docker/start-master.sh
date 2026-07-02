#!/bin/bash
set -e

echo "===================================="
echo " Starting DST Master"
echo "===================================="

: "${CLUSTER_NAME:=MyDediServer}"

SERVER_DIR="/data/server"

cd "$SERVER_DIR/bin64"

exec ./dontstarve_dedicated_server_nullrenderer_x64 \
    -console \
    -cluster "$CLUSTER_NAME" \
    -shard Master