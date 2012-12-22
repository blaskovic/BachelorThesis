#!/bin/bash

function tlBackupTunedProfile()
{
    rlRun "tuned-adm active | awk '{print $NF}' | tee $WORK_DIR/active_profile.backup" 0 "Backing up current tuned profile"
}

function tlRestoreTunedProfile()
{
    rlRun "tuned-adm profile `cat $WORK_DIR/active_profile.backup`" 0 "Restoring tuned profile"
}
