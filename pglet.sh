echo "Pipe name: $1"
page_pipe=$1

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