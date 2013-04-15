#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

# Set number of disks and number of connections to test

rlPhaseStartTest "TEST: Simple speed"
    
    tlVirshStatus || tlVirshStart

    # Testing parameters
    DISK_TYPE=virtio
    declare -A FS
    FS[ext3]="mkfs.ext3 -F"
    FS[ext4]="mkfs.ext4 -F"
    TEST_COMMAND="sync; for i in `seq -s \" \" 1 3`; do dd bs=1G count=1 if=/dev/zero of=/mnt/disk1/test\$i.img; done; for i in `seq -s \" \" 1 3`; do cp -vf /mnt/disk1/test\$i.img /mnt/disk1/test\$i-2.img; done; rm -vrf /mnt/disk1/test*.img; sync;"
    TO_TEST="simple_disk raid0 raid1"

    for FS_NAME in ${!FS[@]}
    do
        rlLog "Start testing for $FS_NAME with command ${FS["$FS_NAME"]}"
        # Set FS command
        FS_COMMAND="${FS["$FS_NAME"]}"

        # Turn tuned off
        rlRun "ssh root@$MACHINE_IP 'systemctl stop tuned.service'"
        sleep 10

        # And now run tests without tuned
        
        for name in $TO_TEST
        do
            . $ORIGINAL_DIR/inc_$name.sh
            tlFileLog "$LOG_FILE" "notuned-$name" "$DISK_TYPE-$FS_NAME-total-time" "$TOTAL_TIME"
        done

        # Turn tuned on
        rlRun "ssh root@$MACHINE_IP 'systemctl start tuned.service'"
        sleep 10

        # And now run tests with tuned
        for name in $TO_TEST
        do
            . $ORIGINAL_DIR/inc_$name.sh
            tlFileLog "$LOG_FILE" "tuned-$name" "$DISK_TYPE-$FS_NAME-total-time" "$TOTAL_TIME"
        done
    done

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
