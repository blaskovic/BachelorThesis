#!/bin/bash

#
# Parse log file and get results
# Author: Branislav Blaskovic
#

logFile=$1

test $# -ne 1 && { echo "You have to specify log file as argument"; exit 1; }

# Log file exists?
test -f $logFile || { echo "Log file '$logFile' does not exists"; exit 1; }

# Include functions
. fun_logger.sh

TESTS="simple_disk raid0 raid1"
DISKS="virtio"
FILESYSTEMS="ext3 ext4"

for fs in $FILESYSTEMS
do

    # Header of table
    echo "\\begin{center}"
    echo "\\begin{tabular}{|l|r|r|r|}"
    echo "    \\hline"
    echo "    \\textbf{Test} & \\textbf{bez tuned} & \\textbf{s tuned} & \\textbf{rozdiel} \\\\ \\hline"
    
    # List results
    for testName in $TESTS
    do
        for disk in $DISKS
        do
            # Get data
            tuned=$( tlFileLogGet $logFile "tuned-$testName" "$disk-$fs-total-time" )
            notuned=$( tlFileLogGet $logFile "notuned-$testName" "$disk-$fs-total-time" )

            # Write to table
            echo -n "    "
            echo -n "${testName//_/\_} $disk $fs & "
            echo -n "$notuned s & $tuned s & $(($notuned - $tuned)) s "
            echo "\\\\"
            echo "    \\hline"
        done
    done

    echo "\\end{tabular}"
    echo "\\end{center}"
    echo
done

