#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck > /dev/null && shellcheck "$0"

# Iterates over all example projects and checks them. This updates lockfiles
# and provides a quick sanity check.
# This script is for development purposes only. In the CI, each example project
# is configured separately.

for contract in ./contracts/*/; do
  echo "Checking $contract ..."
  (
    cd "$contract"
    cargo fmt
    cargo wasm # to make integration tests compile
    cargo check --tests
  )
done