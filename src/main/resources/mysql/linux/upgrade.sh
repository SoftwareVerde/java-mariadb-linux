#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${SCRIPT_DIR}"

port=$1

echo -n "Enter password: "
read -s password

# Linux
LD_LIBRARY_PATH="${SCRIPT_DIR}/lib"
export LD_LIBRARY_PATH


./base/bin/mysql_upgrade -h 127.0.0.1 -P ${port} -u root -p${password}

exit 0

