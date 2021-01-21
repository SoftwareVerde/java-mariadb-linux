#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

interrupt() {
    if [ -f "${pidfile}" ]; then
        kill $(cat "${pidfile}")
    fi
}

trap "interrupt" 1 2 3 6 15 EXIT

cd "${SCRIPT_DIR}"

datadir=$(cd $(cat "${SCRIPT_DIR}/.datadir"); pwd)
pidfile="${datadir}/mysql.pid"
sockfile="${datadir}/mysql.sock"
defaultsfile="${datadir}/mysql.conf"
tmpdir="${datadir}/tmp"

mkdir -p "${tmpdir}"

./base/bin/mysqld --defaults-file=${defaultsfile} --basedir=${SCRIPT_DIR}/base --datadir=${datadir} --socket=${sockfile} --tmpdir=${tmpdir} --pid-file=${pidfile} &

# Wait for stdin before exiting.
# Since STDIN is closed when the parent process disconnects, this guarantees MySQL is always killed.
read tmp

