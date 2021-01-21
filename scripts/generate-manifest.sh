#!/bin/bash

echo -n 'Version: '
read version

build='linux'

cd "src/main/resources/mysql/${build}"
pwd

echo "${version}" > ".version"

previousEntry=''

rm -f manifest
for file in $(find . -type f | sed "s|^\./||" | grep -v 'manifest' | sort | uniq); do
    isExecutable=0
    if [[ -x "${file}" ]]; then
        isExecutable=1
    fi


    # Merge part-files into a single manifest entry.
    if [[ "${file}" =~ .*part[0-9][0-9]*$ ]]; then
        file=$(echo "${file}" | sed -n 's/^\(.*\)\.part[0-9][0-9]*$/\1/p' || echo "${file}")
    fi
    if [[ "${previousEntry}" == "${file}" ]]; then
        continue;
    fi

    previousEntry="${file}"
    echo -n "/mysql/${build}/${file}" >> manifest
    if [[ "${isExecutable}" -eq "1" ]]; then
        echo -n ' x' >> manifest
    fi
    echo >> manifest
done

cat manifest
