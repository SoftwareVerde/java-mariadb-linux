#!/bin/bash

echo -n 'Version: '
read version
echo

build='linux'

resourceDir="src/main/resources/mysql/${build}"

rm -rf "${resourceDir}/*"

cd "mariadb" >/dev/null

manifestFile="$(pwd)/manifest"
versionFile="$(pwd)/.version"

rm -f "${manifestFile}"

echo -n "${version}" > "${versionFile}"

previousEntry=''
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

    echo -n "/mysql/${build}/${file}" >> "${manifestFile}"
    if [[ "${isExecutable}" -eq "1" ]]; then
        echo -n ' x' >> "${manifestFile}"
    fi
    echo >> "${manifestFile}"

    previousEntry="${file}"
done

for file in $(find . -type l | sed "s|^\./||" | grep -v 'manifest' | sort | uniq); do
    # Is symbolic link...

    actualTarget=$(readlink $file)

    echo -n "/mysql/${build}/${file}" >> "${manifestFile}"
    echo -n ' -> ' >> "${manifestFile}"
    echo -n "${actualTarget}" >> "${manifestFile}"
    echo -n ' l' >> "${manifestFile}"
    echo >> "${manifestFile}"
done


cd - >/dev/null

cat "${manifestFile}"
