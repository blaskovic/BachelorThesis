#!/bin/bash

#
# This file needs to be included to test environment
# Prepare disk for attachment
#

# Is this file included?
test x$ORIGINAL_DIR = x && exit 1

# Prepare image
rlRun "dd if=/dev/zero of=disk1.img bs=1G count=8"

# Make filesystem
rlRun "mkfs.ext4 -F disk1.img"

# Prepare device file
cat > deviceVDA.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='`pwd`/disk1.img' bus='sata'/>
<target dev='vda' bus='$DISK_TYPE'/>
</disk>
DELIM

# Attach and mount it
rlRun "virsh attach-device $MACHINE_NAME deviceVDA.xml"
rlRun "ssh root@$MACHINE_IP 'mount /dev/vda /mnt/disk1'"
rlRun "ssh root@$MACHINE_IP 'echo 3 > /proc/sys/vm/drop_caches; sync'"
rlRun "sleep 10"

rlRun "sync"
rlRun "TIME_START=`date '+%s'`"

rlRun "ssh root@$MACHINE_IP '$TEST_COMMAND'"
rlRun "sync"
rlRun "TIME_END=`date '+%s'`"
rlRun "TOTAL_TIME=$(($TIME_END - $TIME_START))"

# Cleanup
rlRun "ssh root@$MACHINE_IP 'umount /mnt/disk1'"
rlRun "virsh detach-device $MACHINE_NAME deviceVDA.xml"