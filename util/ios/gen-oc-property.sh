#! /bin/sh

function help() {
  echo "Usage:"
  echo "    $0 <className> <categoryName> <propertyName> <propertyType> <storageAttribute> <dynamicStorageAttribute>"
  exit -1
}

function to_uppercase() {
  echo $1 | tr [a-z] [A-Z]
}

function capitalize() {
  input=$1
  first=$(to_uppercase `echo $input | cut -c 1`)
  echo "${first}`echo ${input} | cut -c 2-`"
}

if [ $# -lt 6 ] ; then
  help
fi


className=$1 
categoryName=$2 
propertyName=$3 
propertyType=$4 
storageAttribute=$5
dynamicStorageAttribute=$6

categoryNameCapitalized=`capitalize "${categoryName}"`
headerFile="${className}+with${categoryNameCapitalized}.h"

headerCode=`cat <<SS_GEN_OC_CODES
#import "$className.h"

@interface $className ($categoryNameCapitalized) 

@property ($storageAttribute, nonatomic) $propertyType *$propertyName;

@end

SS_GEN_OC_CODES
`
echo "${headerCode}" > "$headerFile"



impFile="${className}+with${categoryNameCapitalized}.m"
propertyNameCapitalized=`capitalize "${propertyName}"`
dynamicKey="\"_______${className}${propertyNameCapitalized}\""

impCode=`cat <<SS_GEN_OC_CODES
#import "${headerFile}"
#include <objc/runtime.h>

@implementation $className ($categoryNameCapitalized) 
- ($propertyType  * _Nullable ) $propertyName {
  return ($propertyType *)objc_getAssociatedObject(self, $dynamicKey);
}

- (void) set${propertyNameCapitalized}:($propertyType *)data {
  objc_setAssociatedObject(
    self,
    $dynamicKey,
    data,
    $dynamicStorageAttribute
  );
}
@end

SS_GEN_OC_CODES
`

echo "${impCode}" > "${impFile}"

