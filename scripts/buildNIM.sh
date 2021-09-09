#!/bin/bash

if [ "$2" = "" ]
then
	echo "$0 [nim-debfile] [image name]"
	exit
fi

DEBFILE=$1
IMGNAME=$2

echo "==> Building NIM docker image"

docker build --build-arg NIM_DEBFILE=$DEBFILE -t $IMGNAME .
docker push $IMGNAME
