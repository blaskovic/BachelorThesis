#!/bin/bash

#
# Sanity test for switching between profiles
# Author: Branislav Blaskovic
#

. bootstrap.sh

rlPhaseStartTest "TEST: Sanity switching profiles"

    rlRun "systemctl start tuned.service"

    rlRun "tuned-adm list | grep ^- | sed 's/- //' > $WORK_DIR/available_profiles"
    
    for profile in `cat $WORK_DIR/available_profiles`
    do
        rlLog "Switch to profile: $profile"
        rlRun "tuned-adm profile $profile"
    done

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
