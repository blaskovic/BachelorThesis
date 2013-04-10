#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

# Set number of disks and number of connections to test

rlPhaseStartTest "TEST: Simple speed"
    
    tlVirshStatus || tlVirshStart

    rlRun "ssh root@$MACHINE_IP 'lsblk'"

    # Turn tuned off
    rlRun "ssh root@$MACHINE_IP 'systemctl stop tuned.service'"
    sleep 10

    # Include simple disk test
    . $ORIGINAL_DIR/test_inc_simple_disk.sh
    tlFileLog "/tmp/tuned-log" "simple-disk-notuned" "total-time" "$TOTAL_TIME"

    # Turn tuned on
    rlRun "ssh root@$MACHINE_IP 'systemctl start tuned.service'"
    sleep 10

    # Include simple disk test
    . $ORIGINAL_DIR/test_inc_simple_disk.sh
    tlFileLog "/tmp/tuned-log" "simple-disk-tuned" "total-time" "$TOTAL_TIME"

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
