#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

execdir=$(pwd)

interrupt() {
    if [ -f "${pidfile}" ]; then
        kill $(cat "${pidfile}")
    fi
}

if [[ -z "$1" ]]; then
    echo "Data directory parameter required."
    exit 1
fi

mkdir -p "$1" || (echo "Unable to create data directory: ${datadir}" && exit 1)
cd "$1"
datadir=$(pwd)
cd -

port="$2"
if [[ -z "${port}" ]]; then
    port=3306
fi

echo -n "New root password: "
read -s password

if [[ -z "${password}" ]]; then
    echo "Password cannot be empty."
    exit 1
fi

pidfile="${datadir}/mysql.pid"
sockfile="${datadir}/mysql.sock"

echo "Data Directory: ${datadir}"

trap "interrupt" 1 2 3 6 15

cd "${SCRIPT_DIR}"

LD_LIBRARY_PATH=./lib
export LD_LIBRARY_PATH

./base/scripts/mysql_install_db --basedir=${SCRIPT_DIR}/base --datadir=${datadir}

./base/bin/mysqld --basedir=${SCRIPT_DIR}/base --datadir=${datadir} --socket=${sockfile} --pid-file=${pidfile} --port=${port} &

sleep 1

printf "\nn\nY\n%s\n%s\nY\nY\nY\nY\n" "${password}" "${password}" | ./base/bin/mysql_secure_installation --basedir=${SCRIPT_DIR}/base --socket=${sockfile}

# Delete the Unix-Socket user.
user=$(whoami)
if [[ "${user}" != "root" ]]; then
    ./base/bin/mysql --socket=${sockfile} -e "DELETE FROM mysql.user WHERE user = '${user}';"
fi

kill $(cat "${pidfile}")

