#!/bin/bash

function tlBackupTunedProfile()
{
    rlLog "Backup tuned profile"
    rlRun "tuned-adm active | awk '{print \$NF}' | awk -F'/' '{print \$(NF - 1)}' | tee active_profile.backup" 0 "Backing up current tuned profile"
}

function tlRestoreTunedProfile()
{
    rlLog "Restore tuned profile"
    [ x`cat active_profile.backup` = x ] || rlRun "tuned-adm profile `cat active_profile.backup`"
}

function tlDropCaches()
{
    rlLog "Dropping pagecache, dentries and inodes"
    rlRun "echo 3 > /proc/sys/vm/drop_caches"
}

function parseDD()
{
    tail -n 1 | awk '{print $(NF - 1)}'
}

function average()
{
    tr '\n' ' ' | awk '{ for (i = 1; i <= NF; i++) sum += $i }; END { print sum/(i-1) }'
}

