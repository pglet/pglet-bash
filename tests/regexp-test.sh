#!/bin/sh

cmd="setf a=b"
if [[ ! "$cmd" =~ \s*\w*f ]]; then
    echo "Take result!"
fi

P='"stackowerflow" is awesome'
echo ${P//\"/\\\"}
echo "aaa=\"${1//\"/\\\"}\""