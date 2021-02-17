#! /bin/bash

if [ $# -ne 3 ]; then
	echo "Error: parameters problem"
	exit 1
fi

user=$1
service=$2
payload=$3

#if directory doesn't exist, then exit
if [ ! -d $user ]; then
  echo "Error: user does not exist"
  exit 1
fi

#if file exist, then exit
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


mkdir -p "$(dirname "$user/$service")" && touch $user/$service

# if mkdir is not successful, then exit
if [ $? -ne 0 ]; then
  exit 1
fi


printf $payload > $user/$service



echo "OK: service created"