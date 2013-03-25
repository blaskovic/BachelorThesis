#!/bin/bash

#
# Compare writing speed to disks with dd
# Author: Branislav Blaskovic
#

. bootstrap.sh

function ddtest()
{
    for i in `seq 1 3`
    do
        rlRun "rm -rf $1-$i.img" 0,1
        rlRun "dd bs=1M count=30 if=/dev/zero of=$1-$i.img conv=fdatasync >& $1-$i.log"
        rlRun "cat $1-$i.log | parseDD >> $1.values"
    done
}

rlPhaseStartTest "TEST: writing to disk with dd"

    rlLog "Testing without tuned daemon" 
    tlDropCaches
    rlRun "systemctl stop tuned.service"
    rlRun "sleep 5"
    ddtest "without-tuned"
    rlRun "cat without-tuned.values"

    rlLog "Testing with tuned daemon" 
    tlDropCaches
    rlRun "systemctl start tuned.service"
    rlRun "sleep 5"
    ddtest "with-tuned"
    rlRun "cat with-tuned.values"
    
    
    rlLog "Average values"
    rlLog "With tuned: `cat with-tuned.values | average` MB/s"
    rlLog "Without tuned `cat without-tuned.values | average` MB/s"


rlPhaseEnd

. $ORIGINAL_DIR/cleanup.sh
