#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck > /dev/null && shellcheck "$0"

# Iterates over all contracts, builds and tests them.
# This script is for development purposes only. In the CI, each contract
# is configured separately.

export RUST_BACKTRACE=1

for contract in ./contracts/*/; do
  echo "Building and testing $contract ..."
  (
    cd "$contract"
    cargo fmt
    cargo build --locked
    cargo unit-test --locked
    cargo wasm --locked
    # cargo integration-test --locked
    cargo schema --locked
  )
done