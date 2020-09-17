#!/usr/bin/env bash
set -eup
shopt -s nullglob
shopt -s globstar 2>/dev/null || true

is_force=false
while [ "$#" -gt 0 ] ; do
  case $1 in
    -f)
      is_force=true
        shift
        ;;
    *)
        shift
        ;;
  esac
done


export install_dir=${HOME}/.config/shellpack/bin
# 覆盖提示
old_contents="$(ls -l "$install_dir" 2>/dev/null || true)"
if [ "$old_contents" != "" ] && ! $is_force ; then
  read -p \
    "$install_dir has following contents: ${old_contents}"$'\n'" u sure to remove them(true|false)?"$'\n' \
    -r confirm
  if ! [ "$(echo "$confirm" | sed 's/[[:space:]]//g')" = 'true' ] ; then
    exit
  fi
fi

rm -rf "$install_dir" 2>/dev/null || true
mkdir -p "$install_dir"

declare -a trees=(core fs ios mobile osx env tool util coc)
for tree in "${trees[@]}" ; do
  cp -a "${tree%%/*}" "$install_dir"
done

search_dirs="$(find "${install_dir%%/}" -type d)"
source_list="$(find "${install_dir%%/}" -name func.sh)"

echo "# paste follow shell code at the end of your .bashrc(recommended) or .bash_profile"
cat <<EOF
shell_pack_loader() {
  IFS=\$'\\n'
  local -a search_dirs=($search_dirs)
  unset IFS
  for subdir in "\${search_dirs[@]}" ; do
    if [ "\$PATH" != "" ] ; then
      export PATH="\${PATH}:\$subdir"
    else
      export PATH="\$subdir"
    fi
  done

  IFS=\$'\\n'
  local -a source_list=($source_list)
  unset IFS
  for func in "\${source_list[@]}" ; do
    . "\$func"
  done
}
shell_pack_loader
EOF
