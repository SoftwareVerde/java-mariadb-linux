#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

execdir=$(pwd)

interrupt() {
    if [ -f "${pidfile}" ]; then
        kill $(cat "${pidfile}")
    fi
}

compute_relative_dir() {
    source="$1"
    target="$2"

    common_part="${source}"
    result=""

    while [[ "${target#$common_part}" == "${target}" ]]; do
        common_part="$(dirname $common_part)"
        if [[ -z "${result}" ]]; then
            result=".."
        else
            result="../${result}"
        fi
    done

    if [[ ${common_part} == "/" ]]; then
        result="${result}/"
    fi

    forward_part="${target#$common_part}"

    if [[ -n "${result}" ]] && [[ -n "${forward_part}" ]]; then
        result="${result}${forward_part}"
    elif [[ -n "${forward_part}" ]]; then
        result="${forward_part:1}"
    fi

    echo "${result}"
}

if [[ -z "$1" ]]; then
    echo "Data directory parameter required."
    exit 1
fi

mkdir -p "$1" || (echo "Unable to create data directory: ${datadir}" && exit 1)
cd "$1"
datadir=$(pwd)
cd -

echo -n "New root password: "
read -s password

if [[ -z "${password}" ]]; then
    echo "Password cannot be empty."
    exit 1
fi

echo -n $(compute_relative_dir "${SCRIPT_DIR}" "${datadir}") > "${SCRIPT_DIR}/.datadir"

pidfile="${datadir}/mysql.pid"
sockfile="${datadir}/mysql.sock"

echo "Data Directory: ${datadir}"

trap "interrupt" 1 2 3 6 15

cd "${SCRIPT_DIR}"

./base/scripts/mysql_install_db --basedir=${SCRIPT_DIR}/base --datadir=${datadir}

./base/bin/mysqld --basedir=${SCRIPT_DIR}/base --datadir=${datadir} --socket=${sockfile} --pid-file=${pidfile} &

sleep 1

printf "\nn\nY\n%s\n%s\nY\nY\nY\nY\n" ${password} ${password} | ./base/scripts/mysql_secure_installation --basedir=${SCRIPT_DIR}/base --socket=${sockfile}

# Delete the Unix-Socket user.
user=$(whoami)
if [[ "${user}" != "root" ]]; then
    ./base/bin/mysql --socket=${sockfile} -e "DELETE FROM mysql.user WHERE user = '${user}';"
fi

kill $(cat "${pidfile}")

