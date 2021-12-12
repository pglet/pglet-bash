#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -e

# include Pglet library
. $DIR/../pglet.sh

PGLET_WEB=true pglet_page

pglet_clean
pglet_add "text value='Hello, world!'"