#! /bin/bash

if [ $# -ne 2 ]; then
	echo "Error: parameters problem"
	exit 1
fi

user=$1
service=$2

if [ ! -d $user ]; then
  echo "Error: user does not exist"
  exit 1
fi

if [ ! -f $user/$service ]; then
  echo "Error: service does not exist"
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

echo -e "$(cat $user/$service)"
