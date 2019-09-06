#!/bin/bash
output="$(pwd)/compile_commands.json"

xcodebuild "$@" | \
  xcpretty --report json-compilation-database  --output "$output"

sed -i -e 's/ -gmodules//g' "$output"
