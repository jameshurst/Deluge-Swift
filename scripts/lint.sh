#!/usr/bin/env bash
set -eu

cd "$(dirname "$(realpath "$0")")/../"
tools/swiftlint.sh Package.swift Sources Tests "$@"
