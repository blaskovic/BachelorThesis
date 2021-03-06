#!/bin/bash

#
# This file needs to be included to test environment
# Prepare disk for attachment
#

# Is this file included?
test x$ORIGINAL_DIR = x && exit 1

# Prepare image
diskDir=`mktemp -d`
chmod 755 $diskDir
rlRun "dd if=/dev/zero of=$diskDir/disk1.img bs=1G count=8"

# Make filesystem
rlRun "$FS_COMMAND $diskDir/disk1.img"

# Prepare device file
cat > deviceVDA.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='$diskDir/disk1.img' bus='sata'/>
<target dev='vda' bus='$DISK_TYPE'/>
</disk>
DELIM

tlVirshStatus || tlVirshStart

# Attach and mount it
rlRun "virsh attach-device $MACHINE_NAME deviceVDA.xml" || failedRunSave

rlRun "ssh root@$MACHINE_IP 'systemctl $TUNED_STATUS tuned.service'"
rlRun "ssh root@$MACHINE_IP 'tuned-adm profile $TUNED_PROFILE'" 0,1,2
sleep 10

rlRun "ssh root@$MACHINE_IP 'mount /dev/vda /mnt/disk1'" || failedRunSave
rlRun "ssh root@$MACHINE_IP 'echo 3 > /proc/sys/vm/drop_caches; sync'" || failedRunSave
rlRun "sleep 10"

rlRun "sync"

failedRunCheck || { rlRun "ssh root@$MACHINE_IP '$TEST_COMMAND'" || failedRunSave; }

rlRun "TIME_HOST_START=`date '+%s'`"
rlRun "sync"
rlRun "TIME_HOST_END=`date '+%s'`"

rlRun "TIME_START=`ssh root@$MACHINE_IP 'cat /tmp/TIME_START'`"
rlRun "TIME_END=`ssh root@$MACHINE_IP 'cat /tmp/TIME_END'`"
rlRun "TOTAL_TIME=$(($TIME_END - $TIME_START + $TIME_HOST_START - $TIME_HOST_END))"

# Cleanup
rlRun "ssh root@$MACHINE_IP 'umount /mnt/disk1'"
rlRun "virsh detach-device $MACHINE_NAME deviceVDA.xml"
tlVirshShutdown
rlRun "rm -rf $diskDir"
