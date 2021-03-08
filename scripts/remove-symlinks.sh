#!/bin/bash

build='linux'

function removeSymlinks() {
    if [[ ! -d $1 ]]; then
        return
    fi

    cd $1
    files=$(find . -type l)
    for file in ${files}; do
        actualTarget=$(readlink $file)
        mv ${actualTarget} ${file}
    done
    cd - >/dev/null
}

removeSymlinks src/main/resources/mysql/${build}/base/bin
removeSymlinks src/main/resources/mysql/${build}/base/scripts
removeSymlinks src/main/resources/mysql/${build}/base/share

