#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck > /dev/null && shellcheck "$0"

gnused="$(command -v gsed || echo sed)"

function print_usage() {
  echo "Usage: $0 NEW_VERSION"
  echo ""
  echo "e.g. $0 0.8.0"
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

# Check repo
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
if [[ "$(realpath "$SCRIPT_DIR/..")" != "$(pwd)" ]]; then
  echo "Script must be called from the repo root"
  exit 2
fi

# Ensure repo is not dirty
CHANGES_IN_REPO=$(git status --porcelain)
if [[ -n "$CHANGES_IN_REPO" ]]; then
    echo "Repository is dirty. Showing 'git status' and 'git --no-pager diff':"
    git status && git --no-pager diff
    exit 3
fi

NEW="$1"

FILES_MODIFIED=()
for contract_dir in ./contracts/*/; do
  CARGO_TOML="$contract_dir/Cargo.toml"
  CARGO_LOCK="$contract_dir/Cargo.lock"

  OLD=$("$gnused" -n -e 's/^version[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' $CARGO_TOML)
  echo "Updating $contract_dir version $OLD to $NEW..."

  "$gnused" -i -e "s/version[[:space:]]*=[[:space:]]*\"$OLD\"/version = \"$NEW\"/" "$CARGO_TOML"
  (cd "$contract_dir" && cargo build)

  FILES_MODIFIED+=("$CARGO_TOML" "$CARGO_LOCK")
done

echo "Staging ${FILES_MODIFIED[*]} ..."
git add "${FILES_MODIFIED[@]}"
git commit -m "chore: add version $NEW"
git tag -a "$NEW" -m "v.$NEW"