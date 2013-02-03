#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

# Set number of disks and number of connections to test
NUM_DISKS=1
NUM_CONNECTIONS=1

rlPhaseStartTest "Create discs"
    
    tlSCSIPrepareDisks $NUM_DISKS $NUM_CONNECTIONS
    tlSCSIConnectDisks
    rlRun "lsblk"
    tlSCSICleanup $NUM_CONNECTIONS

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
