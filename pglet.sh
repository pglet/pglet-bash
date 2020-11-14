# Constants
PGLET_VER="0.1.5"        # Minimum version required by this script

# Default session variables:
PGLET_EXE=""             # full path to Pglet executable
PGLET_CONNECTION_ID=""   # the last page connection ID.
PGLET_PAGE_URL=""        # the last page URL.
PGLET_LAST_RESULT=""     # the last added control ID.
PGLET_EVENT_TARGET=""    # the last received event target (control ID).
PGLET_EVENT_NAME=""      # the last received event name.
PGLET_EVENT_DATA=""      # the last received event data.

# source: https://stackoverflow.com/a/4025065/1435891
function vercomp () {
    if [[ $1 == $2 ]]
    then
        echo "eq"
        return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo "gt"
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo "lt"
            return
        fi
    done
    echo "eq"
}

function pglet_install() {
    if [ "$(uname -m)" != "x86_64" ]; then
        echo "Error: Unsupported architecture $(uname -m). Only x64 binaries are available." 1>&2
        exit 1
    fi

    if [ "$OS" = "Windows_NT" ]; then
        echo "Error: Bash for Windows is not supported." 1>&2
        exit 1
    else
        case $(uname -s) in
        Darwin) target="darwin-amd64.tar.gz" ;;
        *) target="linux-amd64.tar.gz" ;;
        esac
    fi

    # check if there is Pglet aready installed
    pglet_dir="$HOME/.pglet"
    pglet_bin="$pglet_dir/bin"
    PGLET_EXE="$pglet_bin/pglet"

    local ver="$PGLET_VER"
    local installed_ver=""

    if [ -f "$PGLET_EXE" ]; then
        installed_ver=$($PGLET_EXE --version)
    fi

    #echo "Installed version: $installed_ver"

    # compare required and installed versions
    local vc=`vercomp "$installed_ver" "$ver"`

    if [[ "$installed_ver" == "" ]] || [[ "$vc" == "lt" ]]; then
        printf "Installing Pglet v$ver..."

        if [ ! -d "$pglet_bin" ]; then
            mkdir -p "$pglet_bin"
        fi

        local pglet_url="https://github.com/pglet/pglet/releases/download/v${ver}/pglet-${target}"
        local tempTar="$HOME/.pglet/pglet.tar.gz"
        curl -fsSL $pglet_url -o $tempTar
        tar zxf $tempTar -C $pglet_bin
        rm $tempTar

        echo "OK"
    fi
}

# Parameters:
#   $1 - page name
# Variables:
#   PGLET_PUBLIC      - makes the page available as public at pglet.io service or a self-hosted Pglet server
#   PGLET_PRIVATE     - makes the page available as private at pglet.io service or a self-hosted Pglet server
#   PGLET_SERVER      - connects to the page on a self-hosted Pglet server
#   PGLET_TOKEN       - authentication token for pglet.io service or a self-hosted Pglet server

function pglet_page() {
    local pargs=(page)

    if [[ "$1" != "" ]]; then
        pargs+=($1)
    fi

    if [[ "$PGLET_PUBLIC" == "true" ]]; then
        pargs+=(--public)
    fi

    if [[ "$PGLET_PRIVATE" == "true" ]]; then
        pargs+=(--private)
    fi

    if [[ "$PGLET_SERVER" != "" ]]; then
        pargs+=(--server $PGLET_SERVER)
    fi

    if [[ "$PGLET_TOKEN" != "" ]]; then
        pargs+=(--token $PGLET_TOKEN)
    fi

    # execute pglet and get page connection ID
    local page_results=`$PGLET_EXE "${pargs[@]}"`
    IFS=' ' read -r PGLET_CONNECTION_ID PGLET_PAGE_URL <<< "$page_results"

    echo "Page URL: $PGLET_PAGE_URL"
}

function pglet_send() {
    if [[ $# -eq 1 ]]; then
        local conn_id=$PGLET_CONNECTION_ID
        local cmd=$1
    elif [[ $# -eq 2 ]]; then
        local conn_id=$1
        local cmd=$2
    else
        echo "Error: wrong number of arguments"
        exit 1
    fi

    # send command
    echo "$cmd" > "$conn_id"

    # read result
    IFS=' ' read result_status result_value < "$conn_id"
    if [[ "$result_status" == "error" ]]; then
        echo "Error: $result_value"
        exit 2
    fi
}

function pglet_event() {
  # https://askubuntu.com/questions/992439/bash-pass-both-array-and-non-array-parameter-to-function
  arr=("$@")
  IFS=' '
  while true
  do
    read eventTarget eventName eventData < "$page_pipe.events"
    for evt in "${arr[@]}";
    do
      IFS=' ' read -r et en fn <<< "$evt"
      if [[ "$eventTarget" == "$et" && "$eventName" == "$en" ]]; then
        eval "$fn"
        return
      fi      
      #echo "$et - $en - $fn"
    done
  done
}

pglet_install