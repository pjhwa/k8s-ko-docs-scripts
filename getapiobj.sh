#!/bin/bash
#
# This script gets the list of API object for the given version of kubernetes.
# And checks the number of occurrence for each API object in the website/content/en/ directory.
#

if [ "${1}x" == "x" ]; then
  echo "Usage: $0 [kubernetes_version] [website dir]"
  exit 1
else
  if [ -f ./swagger.json ]; then
    rm -f ./swagger.json
  fi
  wget https://github.com/kubernetes/kubernetes/raw/release-${1}/api/openapi-spec/swagger.json
  apiobj_list=$(cat swagger.json | grep "\"kind\": \"" | awk -F: '{print $2}' | sed -e 's/ //g' -e 's/"//g' -e 's/,//g' | sort | uniq)             

  for apiobjects in ${apiobj_list}
  do
        echo -n "${apiobjects},"
        value1=$(grep -ow "${apiobjects}" -ir ${2}/content/en/* | wc -l)
        value2=$(grep -ow "${apiobjects}s" -ir ${2}/content/en/* | wc -l)
        total=$(($value1+$value2))
        echo $total
  done
fi
