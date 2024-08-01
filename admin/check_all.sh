#!/bin/bash

set -e

root_dir="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
cd "$root_dir"
source env.sh

passing=0
failing=0
shopt -s globstar
for test in */r*.sh; do
    dir="$(dirname "$test")"
    base="$(basename "$test")"
    pushd $dir
    if sbatch --wait "$base"; then
        passing=$(( passing + 1 ))
        echo "[PASS] $test"
    else
        failing=$(( failing + 1 ))
        echo "[FAIL] $test"
    fi
    popd
done

echo
echo "Summary:"
echo "Passed: $passing tests"
echo "Failed: $failing tests"
