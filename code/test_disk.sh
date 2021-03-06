#!/bin/bash

#
# Author: Branislav Blaskovic
#


#
# Testing parameters
# Include config and bootstrap
#
. config
. bootstrap.sh

# Set number of disks and number of connections to test

rlPhaseStartTest "TEST: Simple speed"
   
    rlLog "Start time: `date`"

    rlRun "sync"

    for FS_NAME in ${!FS[@]}
    do
        rlLog "Start testing for $FS_NAME with command ${FS["$FS_NAME"]}"
        # Set FS command
        FS_COMMAND="${FS["$FS_NAME"]}"

        # And now run tests without tuned
        
        for name in $TO_TEST
        do
            # Loop while test pass without tuned
            TUNED_STATUS="stop"
            failedRunSave
            while failedRunCheck
            do
                tlVirshShutdown
                rlRun "cp -vf $MACHINE_DISK_SOURCE $MACHINE_DISK"
                
                failedRunClear
                . $ORIGINAL_DIR/inc_$name.sh
            done
            tlFileLog "$LOG_FILE" "notuned-$name" "$DISK_TYPE-$FS_NAME-total-time" "$TOTAL_TIME"

            # Test all relevant profiles
            for TUNED_PROFILE in $TUNED_PROFILES
            do
                # Loop while test pass with tuned
                TUNED_STATUS="start"
                failedRunSave
                while failedRunCheck
                do
                    tlVirshShutdown
                    rlRun "cp -vf $MACHINE_DISK_SOURCE $MACHINE_DISK"

                    failedRunClear
                    . $ORIGINAL_DIR/inc_$name.sh
                done
                tlFileLog "$LOG_FILE" "tuned-$TUNED_PROFILE-$name" "$DISK_TYPE-$FS_NAME-total-time" "$TOTAL_TIME"
            done
        done
    done

    rlLog "End time: `date`"

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
