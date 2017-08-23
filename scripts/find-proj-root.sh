#!/bin/sh

scriptPath=$0
scriptDir=""
if [[ $scriptPath == /* ]] ; then
  scriptDir=`dirname $scriptPath`
else
  scriptDir=`pwd`/`dirname $scriptPath`
fi

tmpVar=`pwd`
cd $scriptDir
scriptDir=`pwd`
cd $tmpVar


appRoot=`dirname $scriptDir`
appRoot=`dirname $appRoot`

echo $appRoot

