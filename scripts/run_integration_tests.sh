#!/bin/bash

set -ex

ROOT="scripts/.integration-test"

docker container stop DelugeIntegrationTests 2>/dev/null || true
docker container rm DelugeIntegrationTests 2>/dev/null || true

git clean -dffx $ROOT
git checkout $ROOT
mkdir -p $ROOT/{config,downloads}

docker run \
    -d \
    --name=DelugeIntegrationTests \
    -p 8112:8112 \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    -v "$(pwd)/$ROOT/config:/config" \
    -v "$(pwd)/$ROOT/downloads:/downloads" \
    linuxserver/deluge

set +e

swift test --filter DelugeIntegrationTests

docker container stop DelugeIntegrationTests
docker container rm DelugeIntegrationTests

git checkout $ROOT
