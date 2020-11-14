#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

# include Pglet library
. $DIR/../pglet.sh

PGLET_PUBLIC=false pglet_page

#echo "$PGLET_CONNECTION_ID"

pglet_send "add text value='Hello, world!'"