#! /bin/bash

server_pipe="./server.pipe"

# if script creates pipe, always remove it, no matter what exit type
trap "rm -f $server_pipe" EXIT

if [[ ! -p $server_pipe ]]; then
    mkfifo $server_pipe
fi

if read pipe_input <$server_pipe; then
  # internal field separator IFS - | used to separate elements
  # incoming values are read from pipe and made available in inputs array
  IFS='|' read -ra inputs <<< "$pipe_input"
fi

while true; do
  client_id="${inputs[0]}"
  command="${inputs[1]}"
  case "$command" in
    init)
      user="${inputs[2]}"
      ./init.sh $user > "./$client_id.pipe"
      ;;

     insert)
      user="${inputs[2]}"
      service="${inputs[3]}"
      payload="${inputs[4]}"
      ./insert.sh $user $service $payload > "./$client_id.pipe"
      ;;

     show)
      user="${inputs[2]}"
      service="${inputs[3]}"
      ./show.sh $user $service > "./$client_id.pipe"
      ;;

     update)
      user="${inputs[2]}"
      service="${inputs[3]}"
      f="${inputs[4]}"
      payload="${inputs[5]}"
      ./update.sh $user $service $f $payload > "./$client_id.pipe"
      ;;

     rm)
      user="${inputs[2]}"
      service="${inputs[3]}"
      ./rm.sh $user $service > "./$client_id.pipe"
      ;;

     ls)
      user="${inputs[2]}"
      folder="${inputs[3]}"
      ./ls.sh $user $folder > "./$client_id.pipe"
      ;;

     shutdown)
      exit 0
      ;;

     *)
      echo "Error:bad request"
      exit 1
  esac

  # after executing command, server should waid for further input to continue to run while loop
  if read pipe_input <$server_pipe; then
    IFS='|' read -ra inputs <<< "$pipe_input"
  fi
done

