#!/bin/bash
set -e

# experiments / unit tests shows:
# when creating symbolic link: ln symbolic link simply records the relative source path passed to ln cli,
# thus when resolving symbolic link: if link destination file was relative, it will be based on the link's containing dir

this_file=$(type -p "$0")
if ! echo "$this_file" | grep -E '^/' >/dev/null ; then
  this_file="$(pwd)/$this_file"
fi
this_dir=$(dirname "$this_file")

if ! cd "$this_dir" ; then
  exit 1
fi

echo "constructing directory ..."
set -x
mkdir dira dirb
echo 'original content of dira/filea' >dira/filea
ln -s dira/filea dirb/fileb
set +x

echo
echo
echo "directory structure:"
ls -R

echo
echo
echo "Test 1: cannot read dirb/fileb because its content 'dira/filea' cannot be located starting from dirb"
if [ -z "$(cat dirb/fileb || true)" ] ; then
  echo "Passed!"
else
  echo "Failed!"
fi
echo "-------------------------------------------------------------------------------"

echo
echo
echo "Test 2: read dirb/fileb"
echo "cp whole dira/* to dirb to make it locatable ..."
cp -a dira dirb
echo "new directory structure:"
ls -R

if [ -z "$(cat dirb/fileb || true)" ] ; then
  echo "Failed!"
else
  echo "Passed!"
fi
echo "-------------------------------------------------------------------------------"

echo
echo
echo "Test 3: compare dira/filea and dirb/dira/filea"
echo "modify dirb/dira/filea to verify dira/filea and dirb/dira/filea is two irrelevant files"
echo "modifyed content of filea" >dirb/dira/filea
content1=$(cat dira/filea)
content2=$(cat dirb/dira/filea)
if [ "$content1" = "$content2" ] || [ -z "$content1" ] || [ -z "$content2" ] ; then
  echo "Failed!"
else
  echo "Passed!"
fi

echo
echo
echo "Test 4: cp dirb/fileb to ."
echo "when copy link dirb/fileb to ., it will link to original filea"
cp -PR dirb/fileb .
content1=$(cat dira/filea)
content2=$(cat fileb)
if [ "$content1" != "$content2" ] || [ -z "$content1" ] || [ -z "$content2" ] ; then
  echo "Failed!"
else
  echo "Passed!"
fi
