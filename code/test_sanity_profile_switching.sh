#!/bin/bash

#
# Sanity test for switching between profiles
# Author: Branislav Blaskovic
#

. bootstrap.sh

rlPhaseStartTest "Switching profiles"

    tlBackupTunedProfile

    rlRun "tuned-adm list | grep ^- | sed 's/- //' > $WORK_DIR/available_profiles"
    
    for profile in `cat $WORK_DIR/available_profiles`
    do
        rlLog "Profile: $profile"
    done

    tlRestoreTunedProfile

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
