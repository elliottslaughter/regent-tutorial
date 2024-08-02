#!/bin/bash

set -e

root_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

legion_prof="$root_dir/legion_prof"

mkdir -p "$HOME/public_html"
output_dir="$(mktemp -d -p "$HOME/public_html")"

$legion_prof "$@" -o "$output_dir/legion_prof"

echo
echo "Please open the following URL in your browser:"
echo
echo "https://sapling.stanford.edu/~$USER/$(basename "$output_dir")/legion_prof"
echo
