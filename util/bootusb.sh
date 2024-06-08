#!/usr/bin/env bash
set -eu

iso_file=$1

hdiutil mount "$iso_file"

select_vol() {
  local _IFS="$IFS"
  local -a vols
  IFS=$'\n'
  vols=(`ls -1 /Volumes`)
  IFS="$_IFS"

  select vol in "${vols[@]}" ; do
    if [ -n "$vol" ] ; then
      printf %s "$vol"
      break
    fi
  done
}

get_file_size() {
  local a1 a2 a3 a4 size rest
  read a1 a2 a3 a4 size rest < <(ls -l "$1")
  echo "$size"
}

echo "Select source volumn:"
source_vol=$(select_vol)

echo "Select destination volumn:"
dest_vol=$(select_vol)

install_wim_size=$(get_file_size "/Volumes/${source_vol}/sources/install.wim")

if [ "$install_wim_size" -gt 4294967296 ] ; then
  rsync -avP --exclude='sources/install.wim' "/Volumes/$source_vol/" "/Volumes/$dest_vol/" &
  echo "install.wim is too large: ${install_wim_size}, will split"
  mkdir -p "/Volumes/$dest_vol/sources/"
  wimlib-imagex split "/Volumes/$source_vol/sources/install.wim"  "/Volumes/$dest_vol/sources/install.swm" 3800
else
  rsync -avP "/Volumes/$source_vol/" "/Volumes/$dest_vol/"
fi

hdiutil unmount "/Volumes/$source_vol"
