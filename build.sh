#!/usr/bin/env bash
set -eu

is_force=false
while [ "$#" -gt 0 ] ; do
  case "$1" in
    -f)
      is_force=true
        shift
        ;;
    *)
        shift
        ;;
  esac
done

default_install_dir=~/.config/shellpack/bin
install_dir=${1:-$default_install_dir}

[ -d build ] || mkdir build
./shellpack core fs ios mobile osx env tool util coc >build/install.sh
chmod +x build/install.sh

[ -d "$install_dir" ] || mkdir -p "$install_dir"
old_contents=$(ls -l "$install_dir")
if [ -n "$old_contents" ] && ! $is_force ; then
  read -p \
    "$install_dir has following contents: ${old_contents}"$'\n'" u sure to remove them(true|false)?"$'\n' \
    -r confirm

  if ! [ "$(echo "$confirm" | sed 's/[[:space:]]//g')" = 'true' ] ; then
    exit
  fi
fi

install_sh=$(pwd)/build/install.sh
cd "${install_dir}" || exit 1
rm -rf ./*
"$install_sh"
