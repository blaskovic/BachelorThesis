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

    # And now run tests without tuned
    
    # Simple disk test
    . $ORIGINAL_DIR/inc_simple_disk.sh
    tlFileLog "$LOG_FILE" "notuned-simple-disk" "total-time" "$TOTAL_TIME"
    # RAID-0 test
    . $ORIGINAL_DIR/inc_raid0.sh
    tlFileLog "$LOG_FILE" "notuned-raid0" "total-time" "$TOTAL_TIME"

    # Turn tuned on
    rlRun "ssh root@$MACHINE_IP 'systemctl start tuned.service'"
    sleep 10

    # And now run tests with tuned

    # Simple disk test
    . $ORIGINAL_DIR/inc_simple_disk.sh
    tlFileLog "$LOG_FILE" "tuned-simple-disk" "total-time" "$TOTAL_TIME"
    # RAID-0 test
    . $ORIGINAL_DIR/inc_raid0.sh
    tlFileLog "$LOG_FILE" "tuned-raid0" "total-time" "$TOTAL_TIME"

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
