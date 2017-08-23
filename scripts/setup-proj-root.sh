#!/bin/sh

appRootPath="../build/appRoot.js"

echo "'use strict';" > $appRootPath
echo "approot = '`./find-proj-root.sh`'" >> $appRootPath
echo "module.exports = approot;" >> $appRootPath

