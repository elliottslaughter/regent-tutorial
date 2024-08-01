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
pushd legion/language
# Note: must run this on a compute node
LAUNCHER="srun -n 1 -N 1 -c 40 -p all --exclusive --pty"
DEBUG=1 USE_GASNET=0 USE_CUDA=0 $LAUNCHER ./scripts/setup_env.py --cmake -j20
popd

mkdir -p bin
ln -sf ../legion/language/regent.py bin/regent
