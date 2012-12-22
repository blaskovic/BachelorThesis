#!/bin/bash

# Disc count
num_discs=1

# Connections per disc
num_connections=1

service iptables stop

for bar in `seq -w $num_discs`; do

dd if=/dev/zero of=/tmp/iscsi-disk$bar bs=1M seek=8000 count=2
echo "
unit: sectors

/dev/mpath/1deadbeef1xxxp1 : start=       63, size= 16386237, Id=83
/dev/mpath/1deadbeef1xxxp2 : start=        0, size=        0, Id= 0
/dev/mpath/1deadbeef1xxxp3 : start=        0, size=        0, Id= 0
/dev/mpath/1deadbeef1xxxp4 : start=        0, size=        0, Id= 0
" | sfdisk /tmp/iscsi-disk$bar

done

# Backup
/bin/cp -f /etc/multipath.conf{,.old}
/bin/cp -f /etc/tgt/targets.conf{,.old}

echo " default-driver iscsi" > /etc/tgt/targets.conf

service tgtd restart

for bar in `seq -w 1 $num_connections`
do
   tgtadm --lld iscsi --op new --mode target --tid=$bar --targetname tg$bar:for.all
   for baz in `seq -w 1 $num_discs`
   do
      tgtadm --lld iscsi --op new --mode logicalunit --tid $bar --lun $baz -b /tmp/iscsi-disk$baz
      tgtadm --lld iscsi --op update --mode logicalunit --tid $bar --lun=$baz --params scsi_id="noname$baz"
    done
    tgtadm --lld iscsi --op bind --mode target --tid $bar -I ALL
done

tgtadm --lld iscsi --op show --mode target
