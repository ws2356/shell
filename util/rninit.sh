#!/bin/bash

set -e

npx react-native init "$@"

POSITIONAL=()
while [ "$#" -gt 0 ] ; do
  key="$1"
  case $key in
      --*)
      shift
      if [ "$#" -gt 0 ] && [[ "$1" =~ [^-] ]] ; then
        shift
      fi
      ;;
      *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

project_name="${POSITIONAL[0]}"

cd "$project_name"

try_add_gem() {
  name=$1
  if ! grep "$name" Gemfile >/dev/null; then
    bundle add --skip-install "$name"
  fi
}

add_shell_build_phase() {
  local project_name=$1
  local target_name=$2
  local script_name=$3
  local script_source=$4
  rb_code=$(
  cat <<EOF
require 'xcodeproj'
project_path = '${project_name}.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == '${target_name}' }
target == nil && exit
scripts = target.shell_script_build_phases()
scripts && scripts.find { |s| s.name == 'good script' } && exit
s = target.new_shell_script_build_phase()
s.name = '${script_name}'
s.shell_script = '${script_source}'
project.save
EOF
)
  local one_line
  one_line=$(echo "$rb_code" | tr '\n' ';')
  ruby -e "$one_line"
}


(
cd ios
add_shell_build_phase "$project_name" "$project_name" "SwiftLint" 'find "${SRCROOT}/'"${project_name}"'" -name "*.swift" | grep -E "." >/dev/null || exit 0 ; "${PODS_ROOT}/SwiftLint/swiftlint" --path "${SRCROOT}/'"${project_name}"'"'

test -f Gemfile || bundle init
gem_source_line_re='^[[:space:]]*source[[:space:]]*".+"$'
if grep -E "$gem_source_line_re" Gemfile>/dev/null ; then
  sed -i.bak -E 's/'"$gem_source_line_re"'/source "https:\/\/gems.ruby-china.com\/"/' Gemfile
else
  echo 'source "https://gems.ruby-china.com/"' >>Gemfile
fi
try_add_gem fastlane
try_add_gem xcodeproj
try_add_gem xcpretty
try_add_gem cocoapods
bundle install

target_pat='^target[[:space:]]'"'${project_name}'"'[[:space:]]do$'
sed -i.bak -E \
-e /"$target_pat"'/i\
use_frameworks! \
\
' \
-e /"$target_pat"'/a\
'"\ \ pod 'SwiftyJSON'"'\
'"\ \ pod 'PromisesSwift'"'\
'"\ \ pod 'PromisesObjC'"'\
'"\ \ pod 'UIImage+FBLAdditions', '~> 1.0'"'\
'"\ \ pod 'SwiftLint'"'\
' \
Podfile
bundle exec pod install
)
