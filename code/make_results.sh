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

echo "%"
echo "% START Automatic results"
echo "%"
for fs in $FILESYSTEMS
do

    COUNT=0
    TUNED_SUM=0
    NOTUNED_SUM=0
    DIFF_SUM=0
    PERCENT_SUM=0

    # Header of table
    echo "\\begin{table}[H]"
    echo "\\begin{center}"
    echo "\\begin{tabular}{|l|r|r|r|r|}"
    echo "    \\hline"
    echo "    \\textbf{Test} & \\textbf{bez tuned} & \\textbf{s tuned} & \\textbf{rozdiel} & \\textbf{rozdiel [\%]} \\\\ \\hline"
    
    # List results
    for testName in $TESTS
    do
        for disk in $DISKS
        do
            # Get data
            tuned=$( tlFileLogGet $logFile "tuned-$testName" "$disk-$fs-total-time" )
            notuned=$( tlFileLogGet $logFile "notuned-$testName" "$disk-$fs-total-time" )
            
            # Some math
            let COUNT++
            TUNED_SUM=$(($TUNED_SUM + $tuned))
            NOTUNED_SUM=$(($NOTUNED_SUM + $notuned))
            DIFF_SUM=$(($DIFF_SUM + $notuned - $tuned))
            PERCENT_SUM=$(($PERCENT_SUM + 100 - 100 * $tuned / $notuned))

            # Write to table
            echo -n "    "
            echo -n "${testName//_/\_} $disk $fs & "
            echo -n "${notuned} s & ${tuned} s & $(($notuned - $tuned)) s & `bc <<< \"scale=2;100-100*$tuned/$notuned\"` \% "
            echo "\\\\"
            echo "    \\hline"
        done
    done

    # Averages
    echo -n "    "
    echo -n "\\textbf{Priemery} & "
    echo -n "`bc <<< \"scale=2;$NOTUNED_SUM / $COUNT\"` s & `bc <<< \"scale=2;$TUNED_SUM / $COUNT\"` s & `bc <<< \"scale=2;$DIFF_SUM / $COUNT\"` s & `bc <<< \"scale=2;$PERCENT_SUM/$COUNT\"` \% "
    echo "\\\\"
    echo "    \\hline"

    echo "\\end{tabular}"
    echo "\\caption{Výsledky testov pre súborový systém $fs}"
    echo "\\label{tab:results-$fs}"
    echo "\\end{center}"
    echo "\\end{table}"
    echo
done
echo "%"
echo "% END Automatic results"
echo "%"
echo

