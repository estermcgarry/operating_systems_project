#! /bin/bash

if [ $# -ne 4 ]; then
	echo "Error: parameters problem"
	exit 1
fi

user=$1
service=$2
f=$3
payload=$4


if [ $f != "f" ]; then
  if [ ! -d $user ]; then
    echo "Error: user does not exist"
    exit 1
  fi

  if [ -f $user/$service ]; then
    echo "Error: service already exists"
    exit 1
  fi

  # check if lock exists
  if [ -f "$user/$user.lock" ]; then
      seconds=0   #if locked wait 10 seconds, checking every second if lock removed
      while [ -f "$user/$user.lock" ]
      do
         sleep 1
         # increment seconds waited by 1
         seconds=`expr $seconds + 1`

          if [ $seconds -eq 10 ]
          then
             echo "timed out waiting for file"
             exit;
          fi
      done
  else
      touch "$user/$user.lock"
      trap "rm -f $user/$user.lock" EXIT   #if script creates lock, always remove it, no matter what exit type
  fi

  # -p allows to create multiple directories in one command
  mkdir -p "$(dirname "$user/$service")" && touch $user/$service
  echo $payload > $user/$service

  # if mkdir is not successful, then exit
  if [ $? -ne 0 ]; then
    exit 1
  fi

  echo "OK: service created"

else
    if [ -f $user/$service ]; then
      mkdir -p "$(dirname "$user/$service")" && touch $user/$service
      echo $payload > $user/$service
      echo "OK: service updated"

    else
      mkdir -p "$(dirname "$user/$service")" && touch $user/$service
      echo $payload > $user/$service
      echo "OK: service created"
    fi

fi