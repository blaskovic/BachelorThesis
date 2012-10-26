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

# Variables
WORK_DIR="/tmp/tuned-tests"

# Clean working directory
rm -rf $WORK_DIR
mkdir $WORK_DIR

# Includes
test -f /usr/share/beakerlib/beakerlib.sh && . /usr/share/beakerlib/beakerlib.sh
test -f common_functions.sh && . common_functions.sh
