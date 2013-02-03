#!/bin/bash

#
# Cleanup after testing - need to be included at the end
# Author: Branislav Blaskovic
#

rlPhaseStartTest "Cleanup"

    tlRestoreTunedProfile

    rlLog "Clean working directory"
    rlRun "popd"
    rlRun "rm -rf $WORK_DIR"

    # Return SELinux
    # rlRun "setenforce 1"

rlPhaseEnd

# End the journal
rlJournalEnd
