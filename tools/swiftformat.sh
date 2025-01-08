#!/usr/bin/env bash
set -eu

export REPOSITORY='https://github.com/nicklockwood/SwiftFormat'
export VERSION='0.55.4'
export BIN_NAME='swiftformat'

bash "$(dirname "$(realpath "$0")")"/run_tool.sh "$@"
