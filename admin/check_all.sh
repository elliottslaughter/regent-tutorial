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
    set +e
    sbatch --wait "$base"
    status=$?
    set -e
    popd
    if [[ status -eq 0 ]]; then
        let passing++
        echo "[PASS] $test"
    else
        let failing++
        echo "[FAIL] $test"
    fi
done

echo
echo "Summary:"
echo "Passed: $passing tests"
echo "Failed: $failing tests"
