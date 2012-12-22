#!/bin/bash

#
# Server side
#
function tlSCSIPrepareDisks()
{
    rlLog "tlSCSIPrepareDisks"

    # Disc count
    if [ x$1 = x ]
    then
        num_discs=1
    else
        num_discs=$1
    fi

    # Connections per disc
    if [ x$2 = x ]
    then
        num_connections=1
    else
        num_connections=$2
    fi

    rlRun "service iptables stop"

    for disc in `seq -w $num_discs`
    do

        rm -f /tmp/iscsi-disk$disc
        rlRun "dd if=/dev/zero of=/tmp/iscsi-disk$disc bs=1M seek=8000 count=2"
        echo "unit: sectors

/dev/mpath/1deadbeef1xxxp1 : start=       63, size= 16386237, Id=83
/dev/mpath/1deadbeef1xxxp2 : start=        0, size=        0, Id= 0
/dev/mpath/1deadbeef1xxxp3 : start=        0, size=        0, Id= 0
/dev/mpath/1deadbeef1xxxp4 : start=        0, size=        0, Id= 0
" | sfdisk /tmp/iscsi-disk$disc

    done

    # Backup
    rlRun "cp -f /etc/multipath.conf{,.old}"
    rlRun "cp -f /etc/tgt/targets.conf{,.old}"

    rlRun "echo \" default-driver iscsi\" > /etc/tgt/targets.conf"

    rlRun "service tgtd restart"

    for connection in `seq -w 1 $num_connections`
    do
        rlRun "tgtadm --lld iscsi --op new --mode target --tid=$connection --targetname tg$bar:for.all"
        for disc in `seq -w 1 $num_discs`
        do
            rlRun "tgtadm --lld iscsi --op new --mode logicalunit --tid $connection --lun $disc -b /tmp/iscsi-disk$disc"
            rlRun "tgtadm --lld iscsi --op update --mode logicalunit --tid $connection --lun=$disc --params scsi_id=\"noname$disc\""
        done
        rlRun "tgtadm --lld iscsi --op bind --mode target --tid $connection -I ALL"
    done

    rlRun "tgtadm --lld iscsi --op show --mode target"
}

#
# Client side
#
function tlSCSIConnectDisks()
{
    rlLog "tlSCSIConnectDisks"

    rlRun "service iscsi restart"
    rlRun "iscsiadm -m discovery -t st -p 127.0.0.1"
    rlRun "service iscsi restart"

    rlRun "modprobe dm-multipath"

echo '
defaults {
        udev_dir                /dev
        
}
blacklist {
        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"
        devnode "^hd[a-z]"
        devnode "^sda"
        devnode "^sda[0-9]"
        device {
                vendor DELL
                product "PERC|Universal|Virtual"
        }
}
devices {
        device {
                vendor                  DELL
                product                 MD3000i
                hardware_handler        "1 rdac"
                path_checker            rdac
                path_grouping_policy    group_by_prio
                prio_callout            "/sbin/mpath_prio_rdac /dev/%n"
                failback                immediate
                getuid_callout          "/sbin/scsi_id -g -u -s /block/%n"
        }
}
' >  /etc/multipath.conf

    rlRun "/sbin/multipath -F"
    rlRun "service multipathd restart"
    rlRun "sleep 20"
    rlRun "multipath -ll"
    rlRun "sleep 10"
}

#
# Cleanup
#
function tlSCSICleanup()
{
    rlLog "tlSCSICleanup"

    # Connections per disc
    if [ x$1 = x ]
    then
        num_connections=1
    else
        num_connections=$1
    fi

    rlRun "service iscsi stop"
    rlRun "sleep 2"
    rlRun "/sbin/multipath -F"

    for connection in `seq -w 1 $num_connections`
    do
        rlRun "tgtadm --lld iscsi --op delete --mode target --tid $connection"
    done

    rlRun "service tgtd stop"
    rlRun "/bin/rm -f /etc/multipath.conf"
    rlRun "cp -f /etc/multipath.conf.old /etc/multipath.conf"
    rlRun "cp -f /etc/tgt/targets.conf.old /etc/tgt/targets.conf"
}
