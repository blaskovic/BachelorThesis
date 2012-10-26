#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

rlJournalStart

    rlPhaseStartTest "Switching profiles"

        tlBackupTunedProfile

        rlRun "tuned-adm list | grep ^- | sed 's/- //' > $WORK_DIR/available_profiles"
        
        for profile in `cat $WORK_DIR/available_profiles`
        do
            rlLog "Profile: $profile"
        done

        tlRestoreTunedProfile

    rlPhaseEnd

rlJournalEnd
