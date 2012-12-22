#!/bin/bash

#
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
WORK_DIR="/tmp/tuned-tests"

# Clean working directory
rm -rf $WORK_DIR
mkdir $WORK_DIR

setenforce 0

# Includes
. /usr/share/beakerlib/beakerlib.sh
. fun_overal.sh
. fun_scsi.sh
