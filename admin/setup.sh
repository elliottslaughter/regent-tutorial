#!/bin/bash

set -e

root_dir="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
prefix_dir="$1"

source "$root_dir/env.sh"

mkdir -p "$prefix_dir"
cd "$prefix_dir"

if [[ ! -e legion ]]; then
    git clone git@gitlab.com:StanfordLegion/legion.git
fi
if [[ ! -e legion_release ]]; then
    git clone legion legion_release
fi

# Note: build must run on a compute node
LAUNCHER="srun -n 1 -N 1 -c 40 -p all --exclusive --pty"

pushd legion/language
DEBUG=1 USE_GASNET=0 USE_CUDA=0 $LAUNCHER ./scripts/setup_env.py --cmake -j20
popd

pushd legion_release/language
DEBUG=0 USE_GASNET=0 USE_CUDA=0 $LAUNCHER ./scripts/setup_env.py --cmake -j20
popd

mkdir -p bin
ln -sf ../legion/language/regent.py bin/regent
ln -sf ../legion_release/language/regent.py bin/regent_release
ln -sf "$root_dir/admin/legion_prof_to_public_html.sh" bin/legion_prof_to_public_html

cargo install --all-features --locked --path ../legion/tools/legion_prof_rs --root .
