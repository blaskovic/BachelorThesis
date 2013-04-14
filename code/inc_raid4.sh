#!/bin/bash

#
# This file needs to be included to test environment
# Prepare disk for attachment
#

# Is this file included?
test x$ORIGINAL_DIR = x && exit 1

# Prepare images
rlRun "dd if=/dev/zero of=disk1.img bs=1G count=1"
rlRun "dd if=/dev/zero of=disk2.img bs=1G count=1"
rlRun "dd if=/dev/zero of=disk3.img bs=1G count=1"

# Prepare device file
cat > deviceVDA.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='`pwd`/disk1.img' bus='sata'/>
<target dev='vda' bus='$DISK_TYPE'/>
</disk>
DELIM

cat > deviceVDB.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='`pwd`/disk2.img' bus='sata'/>
<target dev='vdb' bus='$DISK_TYPE'/>
</disk>
DELIM

cat > deviceVDC.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='`pwd`/disk3.img' bus='sata'/>
<target dev='vdc' bus='$DISK_TYPE'/>
</disk>
DELIM

# Attach and mount it
rlRun "virsh attach-device $MACHINE_NAME deviceVDA.xml"
rlRun "virsh attach-device $MACHINE_NAME deviceVDB.xml"
rlRun "virsh attach-device $MACHINE_NAME deviceVDC.xml"

# Make raid
rlRun "ssh root@$MACHINE_IP 'yes | mdadm --create --verbose --force /dev/md0 --level=4 --raid-devices=3 /dev/vda /dev/vdb /dev/vdc'"
rlRun "ssh root@$MACHINE_IP 'mkfs.ext4 -F /dev/md0; mount /dev/md0 /mnt/disk1'"
rlRun "ssh root@$MACHINE_IP 'echo 3 > /proc/sys/vm/drop_caches; sync'"
rlRun "sleep 10"

rlRun "sync"
rlRun "TIME_START=`date '+%s'`"

#rlRun "ssh root@$MACHINE_IP '$TEST_COMMAND'"
rlRun "sync"
rlRun "TIME_END=`date '+%s'`"
rlRun "TOTAL_TIME=$(($TIME_END - $TIME_START))"

# Cleanup
rlRun "ssh root@$MACHINE_IP 'umount /mnt/disk1'"
rlRun "ssh root@$MACHINE_IP 'mdadm --stop /dev/md0'"
rlRun "virsh detach-device $MACHINE_NAME deviceVDA.xml"
rlRun "virsh detach-device $MACHINE_NAME deviceVDB.xml"
rlRun "virsh detach-device $MACHINE_NAME deviceVDC.xml"
