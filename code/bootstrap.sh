#!/bin/bash

#
# Bootstrap for testing - file to start with
# Author: Branislav Blaskovic
#

# Check for root
if [ $UID -ne 0 ]
then
    echo "You are not root"
    exit 1
fi

# Check for beakerlib
if [ ! -f /usr/share/beakerlib/beakerlib.sh ]
then
    echo "No beakerlib file"
    exit 1
fi

# Variables
ORIGINAL_DIR=`pwd`
# WORK_DIR="/tmp/tuned-tests"
WORK_DIR=`mktemp -d`

setenforce 0

# Includes
. /usr/share/beakerlib/beakerlib.sh
. fun_overal.sh
. fun_scsi.sh

# Start Journal of testing
rlJournalStart

rlPhaseStartTest "Bootstrap"

    rlLog "Go to work dir"
    rlRun "pushd $WORK_DIR"

    tlBackupTunedProfile

rlPhaseEnd
