#!/bin/bash

#
# Author: Branislav Blaskovic
#

. bootstrap.sh

# Set number of disks and number of connections to test

rlPhaseStartTest "TEST: Simple speed"
    
    tlVirshStatus || tlVirshStart

    rlRun "ssh root@$MACHINE_IP 'lsblk'"

    # Prepare disk for attachment
    rlRun "dd if=/dev/zero of=disk1.img bs=1G count=2"

    # Make filesystem
    rlRun "mkfs.ext4 -F disk1.img"
    

    # Prepare device file
    cat > deviceVDA.xml \
<<DELIM
<disk type='block' device='disk'>
<driver name='qemu' type='raw' cache='none' io='native'/>
<source dev='`pwd`/disk1.img' bus='sata'/>
<target dev='vda' bus='virtio'/>
</disk>
DELIM

    # Attach and mount it
    rlRun "virsh attach-device $MACHINE_NAME deviceVDA.xml"
    rlRun "ssh root@$MACHINE_IP 'mount /dev/vda /mnt/vda'"
    rlRun "sleep 10"

    rlRun "sync"
    rlRun "date '+%s' > date.start"
    rlRun "ssh root@$MACHINE_IP 'sync; dd bs=1G count=1 if=/dev/zero of=/mnt/vda/test.img'; sync"
    rlRun "sync"
    rlRun "date '+%s' > date.end"
    rlRun "echo \"Total time: $((`cat date.end` - `cat date.start`)) seconds\""

    # Cleanup
    rlRun "ssh root@$MACHINE_IP 'umount /mnt/vda'"
    rlRun "virsh detach-device $MACHINE_NAME deviceVDA.xml"

rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
