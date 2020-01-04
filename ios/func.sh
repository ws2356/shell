#!/usr/bin/env bash

if ! declare -F simget >/dev/null ; then
  simget() {
    local runtimes
    # cast to lowercase
    IFS=$'\n' runtimes=$(xcrun simctl list -j | jq -r '.runtimes | .[] | (.name + "," + .identifier)')
    local -a runtime_versions
    local -A runtime_id_by_version
    local os_version
    local os_id
    for item in ${runtimes} ; do
      os_version=$(printf '%s' "$item" | sed 's/,..*//')
      os_id=$(printf '%s' "$item" | sed 's/[^,]\{1,\},//')
      runtime_id_by_version["$os_version"]=$os_id
      runtime_versions+=("$os_version")
    done
    if [ "${#runtime_id_by_version[@]}" -le 0 ] ; then
      return 1
    fi

    echo "选择系统版本：" 1>&2
    local selected_os_version=
    select item in "${runtime_versions[@]}" ; do
      if [ -z "$item" ] ; then
        continue
      fi
      selected_os_version=$item
      break
    done
    local selected_os_id=${runtime_id_by_version[$selected_os_version]}

    local simulators
    IFS_=$IFS
    IFS=$'\n'
    simulators=($(xcrun simctl list -j | jq -r '.devices["'"${selected_os_id}"'"] | .[] | (.name + "," + .udid)'))
    IFS=$IFS_
    local -a device_names
    local -A device_id_by_name
    local device_name
    local device_id
    for item in "${simulators[@]}" ; do
      device_name=$(printf '%s' "$item" | sed 's/,..*//')
      device_id=$(printf '%s' "$item" | sed 's/[^,]\{1,\},//')
      device_id_by_name["$device_name"]=$device_id
      device_names+=("$device_name")
    done

    echo "选择机型：" 1>&2
    local selected_device_name
    local selected_device_id
    select item in "${device_names[@]}" ; do
      if [ -z "$item" ] ; then
        continue
      fi
      selected_device_name=$item
      break;
    done
    selected_device_id=${device_id_by_name[$selected_device_name]}
    printf '%s' "$selected_device_id"
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
