#! /bin/bash

if [ $# -ne 1 ]; then
	echo "Error: parameters problem"
	exit 1
fi

user=$1

if [ -d $user ]; then
  echo "Error: user already exists"
  exit 1
fi

mkdir $user

# if mkdir is not successful, then exit
if [ $? -ne 0 ]; then
  exit 1
fi

echo "OK: user created"