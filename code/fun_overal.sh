#!/bin/bash

function tlBackupTunedProfile()
{
    rlLog "Backup tuned profile"
    rlRun "tuned-adm active | awk '{print $NF}' | tee active_profile.backup" 0 "Backing up current tuned profile"
}

function tlRestoreTunedProfile()
{
    rlLog "Restore tuned profile"
    rlRun "tuned-adm profile `cat active_profile.backup`" 0 "Restoring tuned profile"
}

function parse_dd()
{
    tail -n 1 | awk '{print $(NF - 1)}'
}
