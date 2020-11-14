# Constants
PGLET_VER="0.1.5"        # Minimum version required by this script

# Default session variables:
PGLET_EXE=""             # full path to Pglet executable
PGLET_CONNECTION_ID=""   # the last page connection ID.
PGLET_CONTROL_ID=""      # the last added control ID.
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

function pglet() {
    # send command
    echo "$1" > "$page_pipe"

    # read result
    IFS=' ' read result_status result_value < "$page_pipe"
    echo $result_value
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