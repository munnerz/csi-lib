#!/usr/bin/env bash

# Copyright 2023 The cert-manager Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" > /dev/null && pwd )"

export GOBIN="${REPO_ROOT}/.bin"
mkdir -p "${GOBIN}"
# Store a copy of the PATH without the hack/bin directory
export ORIGINAL_PATH="${ORIGINAL_PATH:-$PATH}"
# All scripts that source this should prefer tools in hack/bin above others
export PATH="${REPO_ROOT}/hack/bin:$PATH"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
status() {
  echo -e "${GREEN}${1}${NC}${2:-}"
}

warn() {
  echo -e "${YELLOW}${1}${NC}${2:-}"
}

error() {
  echo -e "${RED}${1}${NC}${2:-}"
}

# Enable debugging output for the given command
debug() {
  set -x
  "$@"
  { set +x; } 2>/dev/null
}

exec_go_tool() {
  name="$1"
  package="$2"
  version="$3"
  shift
  shift
  shift

  ensure_go_tool "$name" "$package" "$version"
  exec "$GOBIN/$name" "$@"
}

ensure_go_tool() {
  name="$1"
  package="$2"
  version="${3:-}"

  # Before checking if the tool is installed, ensure the $GOPATH/bin directory is part of our PATH so we can
  # re-use a previously built copy of it if available.
  if [ ! -f "$GOBIN/$name" ] &>/dev/null; then
    install_go_tool "$name" "$package" "$version"
  fi
}

install_go_tool() {
  name="$1"
  package="$2"
  version="${3:-}"

  warn "+++ $name not already installed - building and installing from source..."
  if [ -z "$version" ]; then
    status "+++ Installing ${package}"
    go install "${package}"
  else
    status "+++ Installing ${package}@${version}"
    go install "${package}"@"${version}"
  fi
  status "+++ $name installed successfully"
}
