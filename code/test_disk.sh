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
    FS_COMMAND="mkfs.ext4 -F"
    FS_NAME="ext4"
    TEST_COMMAND="sync; for i in `seq -s \" \" 1 3`; do dd bs=1G count=1 if=/dev/zero of=/mnt/disk1/test\$i.img; done; for i in `seq -s \" \" 1 3`; do cp -vf /mnt/disk1/test\$i.img /mnt/disk1/test\$i-2.img; done; rm -vrf /mnt/disk1/test*.img; sync;"
    TO_TEST="simple_disk raid0 raid1"

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

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
