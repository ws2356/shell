#! /usr/bin/env bash
# grep for code: ignore .git directory

grep --exclude=.tags --exclude-dir=built --exclude-dir=build --exclude-dir=.git "$@"

