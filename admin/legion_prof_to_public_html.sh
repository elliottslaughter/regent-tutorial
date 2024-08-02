#!/bin/bash

set -e

root_dir="$(dirname "${BASH_SOURCE[0]}")"

legion_prof="$root_dir/legion_prof"

mkdir -p "$HOME/public_html"
output_dir="$(mktemp -d -p "$HOME/public_html")"
chmod og+rx "$output_dir"

$legion_prof archive "$@" -o "$output_dir/legion_prof"

echo
echo "Please open the following URL in your browser:"
echo
echo "https://sapling.stanford.edu/~$USER/$(basename "$output_dir")/legion_prof"
echo
