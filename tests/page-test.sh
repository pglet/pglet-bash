#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

# include Pglet library
. $DIR/../pglet.sh

PGLET_NO_WINDOW=true pglet_page "index"

#echo "$PGLET_CONNECTION_ID"

pglet_send "cleanf"
pglet_send "addf text value='Hello world' size=xxLarge"
txt1=`pglet_send "add textbox multiline label=Data"`
pglet_send "addf button id=ok text=OK"

function hello() {
    r=`pglet_send "get $txt1 value"`
    echo "$r"
    echo "PGLET_EXE: $PGLET_EXE"
    echo "PGLET_CONNECTION_ID: $PGLET_CONNECTION_ID"
    echo "PGLET_PAGE_URL: $PGLET_PAGE_URL"
}

#events=("ok click hello")
#pglet_dispatch_events "${events[@]}"

pglet_dispatch_events "ok click hello"

# while true
# do
#     pglet_wait_event
#     if [[ "$PGLET_EVENT_TARGET" == "ok" && "$PGLET_EVENT_NAME" == "click" ]]; then
#         pglet_send "clean page"
#         pglet_send "add text value=\"That's all, folks!\""
#         exit 0
#     fi
# done