#!/bin/sh

SSH_USER=kalo
SSH_HOST=192.168.0.101
SSH_DELAY=100

while true; do

    now=`date`
    echo -n $now trying to connect to $SSH_HOST ...
    ssh -o ConnectTimeout=10 -o BatchMode=yes "$SSH_USER@$SSH_HOST" "sleep $SSH_DELAY && exit"
    if [ $? -eq 0 ]; then

        echo connection successful
    else 

	echo connection lost $?
        sleep $SSH_DELAY
    fi
done
echo
