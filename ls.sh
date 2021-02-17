#! /bin/bash

if [ $# -eq 1 ]; then
  user=$1

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

  echo "OK:" `tree -a "$user"` | base64

elif [ $# -eq 2 ]; then
  user=$1
  folder=$2
  if [ ! -d $user ]; then
    echo "Error: user does not exist"
    exit 1
  fi

  if [ ! -d $user/$folder ]; then
    echo "Error: folder does not exist"
    exit 1
  fi

  # check if lock exists
  if [ -f "$user/$user.lock" ]; then
      seconds=0
      # if locked wait 10 seconds, checking every second if lock removed
      until [ ! $seconds -lt 10 ] | [ ! -f "$user/$user.lock" ]
      do
         sleep 1
         # increment seconds waited by 1
         seconds=`expr $seconds + 1`
      done

  else
      touch "$user/$user.lock"
      # if script creates lock, always remove it, no matter what exit type
      trap "rm -f $user/$user.lock" EXIT
  fi

  echo "OK:"
  tree -a "$user"/"$folder"

else
	echo "Error: parameters problem"
	exit 1
fi
