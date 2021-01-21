#!/bin/bash

# This script will fragment all files that are larger than 64MB into parts with
#   the suffix .partN and delete the original file.  This is intended to
#   facilitate github compatibility.

build='linux'

cd src/main/resources/mysql/${build}

maxSize=33554432

for file in $(find . -type f -size +${maxSize}c); do
    echo "${file}"
    isExecutable=0
    if [[ -x "${file}" ]]; then
        isExecutable=1
    fi

    cd $(dirname "${file}")
    fileBaseName=$(basename "${file}")
    split -b ${maxSize} "${fileBaseName}" "_${fileBaseName}.part"

    i=0
    for part in $(ls "_${fileBaseName}.part"* 2>/dev/null); do
        if [[ "${isExecutable}" -eq "1" ]]; then
            chmod +x "${part}"
        fi
        mv "${part}" "${fileBaseName}.part${i}"
        i=$((i+1))
    done

    rm "${fileBaseName}"
    cd -
done

