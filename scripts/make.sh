#!/bin/bash

# Delete old dependencies
rm -f build/libs/libs/*

./gradlew makeJar && echo $(ls -r build/libs/*.jar | head -1)
exit $?
