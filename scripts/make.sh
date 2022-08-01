#!/bin/bash
build='linux'

# Delete old dependencies
rm -f build/libs/libs/*

# Delete old resources
rm -rf "src/main/resources/mysql/${build}"
mkdir -p "src/main/resources/mysql"

./scripts/remove-bloat.sh

./scripts/fragment-binaries.sh
./scripts/generate-manifest.sh

cp -R "mariadb" "src/main/resources/mysql/${build}"

find "src/main/resources/mysql/${build}" -type l -delete

./gradlew makeJar && echo $(ls -r build/libs/*.jar | head -1)
exit $?
