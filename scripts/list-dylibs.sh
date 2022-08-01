#!/bin/bash

find src/main/resources/mysql/linux/lib -type f -exec otool -L {} \; | grep dylib | sed 's/.*\/\(.*\.dylib\).*/\1/p' | sort | uniq

