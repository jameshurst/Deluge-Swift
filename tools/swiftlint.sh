#!/usr/bin/env bash
set -eu

export REPOSITORY='https://github.com/realm/SwiftLint'
export VERSION='0.57.1'
export BIN_NAME='swiftlint'

bash "$(dirname "$(realpath "$0")")"/run_tool.sh "$@"
