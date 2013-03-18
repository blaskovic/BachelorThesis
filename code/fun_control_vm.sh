#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh

# Global variables
# Set machine name and IP
MACHINE_NAME="F18"
MACHINE_IP="192.168.2.119"

# Do the action
function tlVirshStart()
{
    virsh start "$MACHINE_NAME"
    if [ $? -eq 0 ]
    then
        # Wait until its running
        while :
        do
            ssh root@$MACHINE_IP ':' 2>/dev/null >/dev/null && break
        done
        rlPass "Start of '$MACHINE_IP' was successful"
    else
        rlFail "Problem starting machine $MACHINE_NAME"
    fi
}
function tlVirshShutdown()
{
    virsh shutdown "$MACHINE_NAME"
    # Check if it's stopped
    while virsh list | grep "$MACHINE_NAME" > /dev/null
    do
        :
    done

    rlPass "Shutdown of '$MACHINE_NAME' was successful"
}

function tlVirshStatus()
{
    virsh list | grep "$MACHINE_NAME" > /dev/null
    [ $? -eq 0 ] && return 0 || return 1
}
