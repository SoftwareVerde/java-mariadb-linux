#!/bin/bash

build='linux'

echo -n "New binaries path: "
read sourceDir

destinationDir="src/main/resources/mysql/${build}/base"
cd "${destinationDir}"
files=$(find . -type f | cut -c3-)
cd -

for file in ${files}; do
    newFile="${sourceDir}/${file}"
    if [[ -f "${newFile}" ]]; then
        cp "${newFile}" "${destinationDir}/${file}"
    else
        echo "${newFile} not found."
    fi
done

