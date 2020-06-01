#!/usr/bin/env bash

if ! declare -F simget >/dev/null ; then
  __array_contains() {
    local -n arr=$1
    local item
    for item in "${arr[@]}" ; do
      if [ "${item,,}" = "$2" ] ; then
        return 0
      fi
    done
    return 1
  }
  export -f __array_contains

  simget() {
    local -a runtimes

    local IFS_=$IFS
    IFS=$'\n' runtimes=($(xcrun simctl list -j | jq -r ".devices | keys | .[]"))
    IFS=$IFS_

    local -a displayed_os_list=()

    local ii=0
    while [ "$ii" -lt "${#runtimes[@]}" ] ; do
      local os="${runtimes[ii]}"
      IFS_=$IFS
      IFS=$'\n' devices=($(xcrun simctl list -j | jq -r ".devices[\"$os\"] | .[] | .state"))
      IFS_=$IFS
      if __array_contains devices booted ; then
        displayed_os_list+=("* ${os}")
      else
        displayed_os_list+=("  ${os}")
      fi
      ii=$((ii + 1))
    done

    local selected_os=
    select selected_os in "${displayed_os_list[@]}" ; do
      if [ -z "$selected_os" ] ; then
        continue
      fi
      break
    done

    selected_os="${selected_os##\*}"
    selected_os="${selected_os## }"

    local -a devices
    local device
    IFS_=$IFS
    IFS=$'\n' devices=($(xcrun simctl list -j | jq -r \
      ".devices[\"$selected_os\"]"' | map(select(.isAvailable)) | .[] | {Shutdown:" ", Booted:"*"}[.state] + " " + .udid + ", " + .name'))
          IFS_=$IFS

    select device in "${devices[@]}" ; do
      if [ -z "$device" ] ; then
        continue
      fi
      printf '%s' "$device" | sed -n 's/^\*\{0,1\}[[:space:]]*\([-[:alnum:]]\{1,\}\).*$/\1/p'
      break
    done
  }
  export -f simget
else
  echo "Duplicated func definition, ignoring: simget @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F get_default_sdk_name >/dev/null ; then
  get_default_sdk_name() {
    # looks those two are the same
    get_default_platform
  }
  export -f get_default_sdk_name
else
  echo "Duplicated func definition, ignoring: get_default_sdk_name @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F get_default_platform >/dev/null ; then
  get_default_platform() {
    printf '%s' iphoneos
  }
  export -f get_default_platform
else
  echo "Duplicated func definition, ignoring: get_default_platform @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F get_default_ios_version >/dev/null ; then
  get_default_ios_version() {
    xcrun -sdk "$(get_default_sdk_name)" -show-sdk-version
  }
  export -f get_default_ios_version
else
  echo "Duplicated func definition, ignoring: get_default_ios_version @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F get_default_ios_sdk_path >/dev/null ; then
  get_default_ios_sdk_path() {
    xcrun -sdk "$(get_default_sdk_name)" -show-sdk-path
  }
  export -f get_default_ios_sdk_path
else
  echo "Duplicated func definition, ignoring: get_default_ios_sdk_path @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F get_swift_host_triplet >/dev/null ; then
  get_swift_host_triplet() {
    local platform=${1:-$(get_default_platform)}
    local version=${2:-$(get_default_ios_version)}

    local arch=
    case $platform in
      iphoneos)
        arch=arm64
        ;;
      *)
        arch=x86_64
        ;;
    esac
    local os=
    case ${platform} in
      macos)
        os=macos
        ;;
      *)
        os=ios
        ;;
    esac
    printf '%s' "${arch}-apple-${os}${version}-${platform}"
  }
  export -f get_swift_host_triplet
else
  echo "Duplicated func definition, ignoring: get_swift_host_triplet @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F guess_swift_host_triplet >/dev/null ; then
  guess_swift_host_triplet() {
    local os
    os=$(basename "$(xcrun --toolchain swift  --show-sdk-platform-path)" '.platform')
    os=${os,,*}
    local version
    version=$(xcrun --toolchain swift  --show-sdk-version)
    local arch
    case $os in
      macosx)
        arch=x86_64;;
      *simulator*)
        arch=x86_64;;
      *iphone*)
        arch=arm64;;
      *)
        arch=armv7;;
    esac
    printf '%s' "${arch}-apple-${os}${version}"
  }
  export -f guess_swift_host_triplet
else
  echo "Duplicated func definition, ignoring: guess_swift_host_triplet @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F devget >/dev/null ; then
  devget() {
    IFS_=$IFS
    IFS=$'\n' list=($(cfgutil --format JSON list | jq -r '.Output | values | .[] | .ECID + ", " + .name'))
    IFS=$IFS_
    ecid=
    select item in "${list[@]}" ; do
      if [ -z "$item" ] ; then
        continue
      fi
      ecid="$(printf '%s' "$item" | sed 's/^[[:blank:]]*\([[:alnum:]]\{1,\}\).*$/\1/')"
      break
    done
    printf '%s' "$ecid"
  }
  export -f devget
else
  echo "Duplicated func definition, ignoring: devget @${BASH_SOURCE[0]}:${LINENO}"
fi

