#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

# Set number of disks and number of connections to test
NUM_DISKS=1
NUM_CONNECTIONS=1

rlJournalStart

    rlPhaseStartTest "Create discs"
        
        tlSCSIPrepareDisks $NUM_DISKS $NUM_CONNECTIONS
        tlSCSIConnectDisks
        lsblk
        tlSCSICleanup $NUM_CONNECTIONS

    rlPhaseEnd

rlJournalEnd
