#!/usr/bin/env bash
set -eu
[[ "${TRACE:-}" == 1 ]] && set -x

root_dir=$(dirname "$(realpath "$0")")

tool_name=${REPOSITORY##*/}
tool_bin=${root_dir}/.bin/${tool_name}/${VERSION}/${BIN_NAME}

if [[ ! -x "${tool_bin}" ]]; then
  checkout_dir=${root_dir}/.checkout/${tool_name}
  rm -rf "${checkout_dir}"
  git clone --branch="${VERSION}" --depth=1 "${REPOSITORY}" "${checkout_dir}"
  pushd "${checkout_dir}"
  swift build --configuration=release
  mkdir -p "$(dirname "${tool_bin}")"
  mv .build/release/"${BIN_NAME}" "${tool_bin}"
  popd
  rm -rf "${checkout_dir}"
fi

"${tool_bin}" "$@"
