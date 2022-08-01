#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -z "$1" ]]; then
    echo "Data directory parameter required."
    exit 1
fi

mkdir -p "$1" || (echo "Unable to create data directory: ${datadir}" && exit 1)
cd "$1"
datadir=$(pwd)
cd -

echo "Data Directory: ${datadir}"

cd "${SCRIPT_DIR}"

./base/scripts/mysql_install_db --auth-root-authentication-method=normal --skip-name-resolve --skip-name-resolve --basedir=${SCRIPT_DIR}/base --datadir=${datadir}

# Linux
# LD_LIBRARY_PATH="${SCRIPT_DIR}/lib"
# export LD_LIBRARY_PATH

# OSX
# DYLD_LIBRARY_PATH="${SCRIPT_DIR}/lib";
# export DYLD_LIBRARY_PATH

