#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

# include Pglet library
. $DIR/../pglet.sh

function hello() {
    pglet_send "clean page"
    pglet_send "add text value=\"That's all, folks!\""
}

function main() {
    pglet_send "add text value='Hello, world!'"
    pglet_send "add button id=ok text=OK"
    pglet_dispatch_events "ok click hello"
}

pglet_app "app2" "main"