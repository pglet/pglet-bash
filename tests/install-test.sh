#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

# pglet is getting installed while loading the script
. $DIR/../pglet.sh