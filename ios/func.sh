#!/usr/bin/env bash

if ! declare -F simget >/dev/null ; then
  __array_contains() {
    local arr_name=$1
    local arr_len=0
    arr_len="$(eval 'printf %s ${#'"${arr_name}[@]}")"
    if [ "${arr_len}" -lt 1 ] ; then
      return 1
    fi

    local ii
    local item
    for ii in $(seq 0 "$((arr_len - 1))") ; do
      item="$(eval 'printf %s ${'"${arr_name}[$ii]}")"
      if [ "$(echo "$item" | tr '[:upper:]' '[:lower:]')" = "$2" ] ; then
        return 0
      fi
    done
    return 1
  }
  export -f __array_contains

  simget() {
    local -a runtimes

    IFS=$'\n' runtimes=($(xcrun simctl list -j | jq -r ".devices | keys | .[]"))
    unset IFS

    local -a displayed_os_list=()

    local ii=0
    while [ "$ii" -lt "${#runtimes[@]}" ] ; do
      local os="${runtimes[ii]}"
      IFS=$'\n' devices=($(xcrun simctl list -j | jq -r ".devices[\"$os\"] | .[] | .state"))
      unset IFS
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

    # still not familar with bash pattern
    # selected_os="${selected_os##\*}"
    # selected_os="${selected_os## }"
    selected_os="$(printf '%s' "$selected_os" | sed 's/^[*[:blank:]]\{1,\}//')"

    local -a devices
    local device
    IFS=$'\n' devices=($(xcrun simctl list -j | jq -r \
      ".devices[\"$selected_os\"]"' | map(select(.isAvailable)) | .[] | {Shutdown:" ", Booted:"*"}[.state] + " " + .udid + ", " + .name'))
    unset IFS
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


# 传入sdk名字，如iphoneos, macosx, iphonesimulator
if ! declare -F get_platform_name >/dev/null ; then
  get_platform_name() {
    printf '%s' "$SDK_NAME"
  }
  export -f get_platform_name
else
  echo "Duplicated func definition, ignoring: get_platform_name @${BASH_SOURCE[0]}:${LINENO}"
fi


# 传入部署版本，默认sdk版本
if ! declare -F get_deploy_target_version >/dev/null ; then
  get_deploy_target_version() {
    if [ -n "${DEPLOY_TARGET:-}" ] ; then
      printf '%s' "$DEPLOY_TARGET"
    else
      get_sdk_version
    fi
  }
  export -f get_deploy_target_version
else
  echo "Duplicated func definition, ignoring: get_deploy_target_version @${BASH_SOURCE[0]}:${LINENO}"
fi


if ! declare -F get_sdk_version >/dev/null ; then
  get_sdk_version() {
    xcrun -sdk "$SDK_NAME" -show-sdk-version
  }
  export -f get_sdk_version
else
  echo "Duplicated func definition, ignoring: get_sdk_version @${BASH_SOURCE[0]}:${LINENO}"
fi


if ! declare -F get_sdk_path >/dev/null ; then
  get_sdk_path() {
    xcrun -sdk "$SDK_NAME" -show-sdk-path
  }
  export -f get_sdk_path
else
  echo "Duplicated func definition, ignoring: get_sdk_path @${BASH_SOURCE[0]}:${LINENO}"
fi


# target triplet
if ! declare -F get_target_triplet >/dev/null ; then
  get_target_triplet() {
    local sdk_name=${SDK_NAME}
    local version
    version=$(get_deploy_target_version)

    local arch=
    case $sdk_name in
      iphoneos)
        arch=arm64
        ;;
      *)
        arch=x86_64
        ;;
    esac

    local os=
    case ${sdk_name} in
      macos*)
        os=macosx
        ;;
      *)
        os=ios
        ;;
    esac

    local env_field=
    case "$sdk_name" in
      *simulator)
        env_field=simulator
        ;;
      *)
        ;;
    esac

    if [ -n "$env_field" ] ; then
      printf '%s-apple-%s%s-%s' "${arch}" "${os}" "${version}" "${sdk_name}"
    else
      printf '%s-apple-%s%s' "${arch}" "${os}" "${version}"
    fi
  }
  export -f get_target_triplet
else
  echo "Duplicated func definition, ignoring: get_target_triplet @${BASH_SOURCE[0]}:${LINENO}"
fi


if ! declare -F spmbuild >/dev/null ; then
  spmbuild() {
    declare -r POSITIONAL=()
    local is_verbose=false
    while [ "$#" -gt 0 ] ; do
      case "$1" in
        -v|--verbose)
            is_verbose=true
            shift
            ;;
        *)
          POSITIONAL+=("$1")
            shift
            ;;
      esac
    done
    if $is_verbose ; then
      set -x
    fi
    xcrun swift build -Xswiftc -sdk -Xswiftc "$(get_sdk_path)" \
      -Xswiftc -target -Xswiftc "$(get_target_triplet)"
    if $is_verbose ; then
      set +x
    fi
  }
  export -f spmbuild
else
  echo "Duplicated func definition, ignoring: spmbuild @${BASH_SOURCE[0]}:${LINENO}"
fi



if ! declare -F devget >/dev/null ; then
  devget() {
    IFS=$'\n' list=($(cfgutil --format JSON list | jq -r '.Output | values | .[] | .ECID + ", " + .name'))
    unset IFS
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

