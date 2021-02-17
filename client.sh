#! /bin/bash

server_pipe="./server.pipe"


client_id=$1
client_pipe="./$client_id.pipe"

# if script creates pipe, always remove it, no matter what exit type
trap "rm -f $client_pipe" EXIT
# if client pipe doesn't exist, create one
if [[ ! -p $client_pipe ]]; then
  mkfifo $client_pipe
fi

command=$2
case "$command" in
  init)
    if [ $# -eq 3 ]; then
      user=$3
      echo "$client_id|$command|$user" >$server_pipe
    else
      echo "Error: parameters problem"
      exit 1
    fi
    ;;

  insert)
    if [ $# -eq 4 ]; then
      user=$3
      service=$4
      printf "Please write login: "
      read -a login
      printf "Please write password: "
      read -a password
      echo "$client_id|$command|$user|$service|login:$login\npassword:$password" >$server_pipe
    else
      echo "Error: parameters problem"
      exit 1
    fi
    ;;

  show)
    if [ $# -eq 4 ]; then
      user=$3
      service=$4
      echo "$client_id|$command|$user|$service" >$server_pipe
    else
      echo "Error: parameters problem"
      exit 1
    fi
    ;;


  ls)
    if [ $# -eq 3 ]; then
      user=$3
      echo "$client_id|$command|$user" >$server_pipe

    elif [ $# -eq 4 ]; then
      user=$3
      service=$4
      echo "$client_id|$command|$user|$service" >$server_pipe

    else
      echo "Error: parameters problem"
      exit 1
    fi
    read pipe_output <$client_pipe
    echo $pipe_output | base64 --decode
    exit 0
    ;;

  edit)
    if [ $# -eq 4 ]; then
      user=$3
      service=$4
      # send request for information from server on service
      echo "$client_id|show|$user|$service" >$server_pipe
      # wait for response from server and put response into pipe_output
      read pipe_output <$client_pipe
      # create temp file so user can edit information
      tempfile=mktemp
      echo $pipe_output > $tempfile
      vi $tempfile
      # execute command cat to put it into varibale to be sent to server_pipe
      payload=`cat $tempfile`
      echo "$client_id|update|$user|$service|f|$payload" >$server_pipe
      # temp file not necessary anymore and could contain sensitive information, so delete
      rm $tempfile
    else
      echo "Error: parameters problem"
      exit 1
    fi
    ;;

  rm)
    if [ $# -eq 4 ]; then
      user=$3
      service=$4
      echo "$client_id|$command|$user|$service" >$server_pipe
    else
      echo "Error: parameters problem"
      exit 1
    fi
    ;;

  shutdown)
      echo "$client_id|shutdown" >$server_pipe
      exit 0
      ;;

  *)
    echo "Error: bad request"
    exit 1
esac


read pipe_output <$client_pipe
echo $pipe_output
rm $client_pipe