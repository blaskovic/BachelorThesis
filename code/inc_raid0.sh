#!/bin/bash

#
# This file needs to be included to test environment
# Prepare disk for attachment
#

# Is this file included?
test x$ORIGINAL_DIR = x && exit 1

# Prepare images
diskDir=`mktemp -d`
chmod 755 $diskDir
rlRun "dd if=/dev/zero of=$diskDir/disk1.img bs=1G count=4"
rlRun "dd if=/dev/zero of=$diskDir/disk2.img bs=1G count=4"

# Prepare device file
cat > deviceVDA.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='$diskDir/disk1.img' bus='sata'/>
<target dev='vda' bus='$DISK_TYPE'/>
</disk>
DELIM

cat > deviceVDB.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='$diskDir/disk2.img' bus='sata'/>
<target dev='vdb' bus='$DISK_TYPE'/>
</disk>
DELIM

tlVirshStatus || tlVirshStart

# Attach and mount it
rlRun "virsh attach-device $MACHINE_NAME deviceVDA.xml" || failedRunSave
rlRun "virsh attach-device $MACHINE_NAME deviceVDB.xml" || failedRunSave

rlRun "ssh root@$MACHINE_IP 'systemctl $TUNED_STATUS tuned.service'"
rlRun "ssh root@$MACHINE_IP 'tuned-adm profile $TUNED_PROFILE'" 0,1,2
sleep 10

# Make raid
rlRun "ssh root@$MACHINE_IP 'yes | mdadm --create --verbose --force /dev/md0 --level=stripe --raid-devices=2 /dev/vda /dev/vdb'" || failedRunSave
rlRun "ssh root@$MACHINE_IP '$FS_COMMAND /dev/md0; mount /dev/md0 /mnt/disk1'" || failedRunSave
rlRun "ssh root@$MACHINE_IP 'echo 3 > /proc/sys/vm/drop_caches; sync'" || failedRunSave

rlRun "sync"
rlRun "TIME_START=`date '+%s'`"

failedRunCheck || { rlRun "ssh root@$MACHINE_IP '$TEST_COMMAND'" || failedRunSave; }

rlRun "TIME_HOST_START=`date '+%s'`"
rlRun "sync"
rlRun "TIME_HOST_END=`date '+%s'`"

rlRun "TIME_START=`ssh root@$MACHINE_IP 'cat /tmp/TIME_START'`"
rlRun "TIME_END=`ssh root@$MACHINE_IP 'cat /tmp/TIME_END'`"
rlRun "TOTAL_TIME=$(($TIME_END - $TIME_START + $TIME_HOST_START - $TIME_HOST_END))"

# Cleanup
rlRun "ssh root@$MACHINE_IP 'umount /mnt/disk1'"
rlRun "ssh root@$MACHINE_IP 'mdadm --stop /dev/md0'"
rlRun "virsh detach-device $MACHINE_NAME deviceVDA.xml"
rlRun "virsh detach-device $MACHINE_NAME deviceVDB.xml"
tlVirshShutdown
rlRun "rm -rf $diskDir"
