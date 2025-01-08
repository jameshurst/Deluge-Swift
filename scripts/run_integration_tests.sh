#!/usr/bin/env bash
set -eux

DOCKER_VOLUME_ROOT="scripts/.integration-test"

if command -v podman >/dev/null; then
  DOCKER=podman
  DOCKER_ADDITIONAL_ARGS=(--user=0:0 --userns=keep-id)
elif command -v docker >/dev/null; then
  DOCKER=docker
  DOCKER_ADDITIONAL_ARGS=()
fi

"${DOCKER}" container stop DelugeIntegrationTests 2>/dev/null || true
"${DOCKER}" container rm DelugeIntegrationTests 2>/dev/null || true

git clean -dffx "${DOCKER_VOLUME_ROOT}"
git checkout "${DOCKER_VOLUME_ROOT}"
mkdir -p "${DOCKER_VOLUME_ROOT}"/{config,downloads}

"${DOCKER}" run \
  --name=DelugeIntegrationTests \
  -p 127.0.0.1:8112:8112 \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -v "./${DOCKER_VOLUME_ROOT}/config:/config" \
  -v "./${DOCKER_VOLUME_ROOT}/downloads:/downloads" \
  -d \
  "${DOCKER_ADDITIONAL_ARGS[@]}" \
  linuxserver/deluge

sleep 5

swift test --filter DelugeIntegrationTests && RC=$? || RC=$?

"${DOCKER}" container stop DelugeIntegrationTests
"${DOCKER}" container rm DelugeIntegrationTests

git clean -dffx "${DOCKER_VOLUME_ROOT}"
git checkout "${DOCKER_VOLUME_ROOT}"

exit "${RC}"
