#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh

# Set machine name and IP
if [ x"$2" = "x" ]
then
    MACHINE_NAME="F18"
else
    MACHINE_NAME=$2
fi

if [ x"$3" = "x" ]
then
    MACHINE_IP="192.168.2.119"
else
    MACHINE_IP=$3
fi

# Do the action
case $1 in
    start)
        virsh start "$MACHINE_NAME"
        if [ $? -eq 0 ]
        then
            # Wait until its running
            while :
            do
                ssh root@$MACHINE_IP ':' 2>/dev/null >/dev/null && exit 0
            done
        else
            echo "Problem starting machine $MACHINE_NAME"
            exit 1
        fi
    ;;
    shutdown)
        virsh shutdown "$MACHINE_NAME"
        # Check if it's stopped
        while virsh list | grep "$MACHINE_NAME" > /dev/null
        do
            :
        done
        exit 0
    ;;

    status)
        virsh list | grep "$MACHINE_NAME" > /dev/null
        [ $? -eq 0 ] && exit 0 || exit 1
    ;;

    *)
        echo "Bad command" >&2
        exit 2
    ;;
esac
