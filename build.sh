#!/usr/bin/env bash
[ -d build ] || mkdir build
./shellpack core fs ios mobile osx >build/install.sh
chmod +x build/install.sh
