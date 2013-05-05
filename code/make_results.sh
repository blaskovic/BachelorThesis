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

# Include config
. config

echo "%"
echo "% START Automatic results"
echo "%"

for profile in $TUNED_PROFILES
do
    # Heading
    echo "\\subsection{Testovanie s profilom \\emph{$profile}}"

    # Include text for results if exists
    echo "\\IfFileExists{obsah-test-$profile}{\\input{obsah-test-$profile}}{}"
    echo

        # Header of table
        echo "{\\renewcommand{\\arraystretch}{1.1}"
        echo "\\begin{table}[H]"
        echo "\\begin{center}"
        echo "\\begin{tabular}{|l|r r r r|}"
        echo "    \\hline"
        echo "    \\textbf{Test} & \\textbf{bez tuned} & \\textbf{s tuned} & \\textbf{rozdiel} & \\textbf{rozdiel [\%]} \\\\"
        

    COUNT_PROF=0
    TUNED_SUM_PROF=0
    NOTUNED_SUM_PROF=0
    DIFF_SUM_PROF=0
    PERCENT_SUM_PROF=0


    for fs in ${!FS[@]}
    do

        COUNT=0
        TUNED_SUM=0
        NOTUNED_SUM=0
        DIFF_SUM=0
        PERCENT_SUM=0

        let COUNT_PROF++

        echo "    \\hline & \\\\[-1em]\\hline"

        # List results
        for testName in $TO_TEST
        do
            for disk in $DISK_TYPE
            do
                # Get data
                tuned=$( tlFileLogGet $logFile "tuned-$profile-$testName" "$disk-$fs-total-time" )
                notuned=$( tlFileLogGet $logFile "notuned-$testName" "$disk-$fs-total-time" )

                [ x = x$tuned ] && { echo "Error reading 'tuned-$profile-$testName' '$disk-$fs-total-time'" >&2; continue;  }
                [ x = x$notuned ] && { echo "Error reading 'notuned-$testName' '$disk-$fs-total-time'" >&2; continue;  }
                
                # Some math
                let COUNT++
                TUNED_SUM=$(($TUNED_SUM + $tuned))
                NOTUNED_SUM=$(($NOTUNED_SUM + $notuned))
                DIFF_SUM=$(($DIFF_SUM + $notuned - $tuned))
                PERCENT_SUM=$(($PERCENT_SUM + 100 - 100 * $tuned / $notuned))


                # Write to table
                echo -n "    "
                echo -n "${testName//_/\_} $fs & "
                echo -n "${notuned}\\,s & ${tuned}\\,s & $(($notuned - $tuned))\\,s & `bc <<< \"scale=2;100-100*$tuned/$notuned\"`\\,\% "
                echo "\\\\"
            done
        done

        # Averages
        AVG_NOTUNED="`echo $NOTUNED_SUM $COUNT | awk '{printf "%.2f", $1 / $2}'`"
        AVG_TUNED="`echo $TUNED_SUM $COUNT  | awk '{printf "%.2f", $1 / $2}'`"
        AVG_DIFF="`echo $DIFF_SUM $COUNT | awk '{printf "%.2f", $1 / $2}'`"
        AVG_PERCENT="`echo $PERCENT_SUM $COUNT | awk '{printf "%.2f", $1 / $2}'`"

        # Sum it up for averages
        TUNED_SUM_PROF=`echo $TUNED_SUM_PROF $AVG_TUNED | awk '{printf "%.2f", $1 + $2'}`
        NOTUNED_SUM_PROF=`echo $NOTUNED_SUM_PROF $AVG_NOTUNED | awk '{printf "%.2f", $1 + $2'}`
        DIFF_SUM_PROF=`echo $DIFF_SUM_PROF $AVG_DIFF | awk '{printf "%.2f", $1 + $2'}`
        PERCENT_SUM_PROF=`echo $PERCENT_SUM_PROF $AVG_PERCENT | awk '{printf "%.2f", $1 + $2'}`

        echo "    \\hline"
        echo -n "    "
        echo -n "\\textbf{Priemery} & "
        echo -n "\\textbf{$AVG_TUNED s}\\,& \\textbf{$AVG_TUNED\\,s} & \\textbf{$AVG_DIFF\\,s} & \\textbf{$AVG_PERCENT\\,\%} "
        echo "\\\\"

    done

    echo "    \\hline & \\\\[-1em]\\hline"

    # Averages for profile
    PROF_AVG_NOTUNED="`echo $NOTUNED_SUM_PROF $COUNT_PROF | awk '{printf "%.2f", $1 / $2}'`"
    PROF_AVG_TUNED="`echo $TUNED_SUM_PROF $COUNT_PROF  | awk '{printf "%.2f", $1 / $2}'`"
    PROF_AVG_DIFF="`echo $DIFF_SUM_PROF $COUNT_PROF | awk '{printf "%.2f", $1 / $2}'`"
    PROF_AVG_PERCENT="`echo $PERCENT_SUM_PROF $COUNT_PROF | awk '{printf "%.2f", $1 / $2}'`"

    echo -n "    "
    echo -n "\\textbf{Celkové priemery} & "
    echo -n "\\textbf{$PROF_AVG_TUNED s}\\,& \\textbf{$PROF_AVG_TUNED\\,s} & \\textbf{$PROF_AVG_DIFF\\,s} & \\textbf{$PROF_AVG_PERCENT\\,\%} "
    echo "\\\\"

    echo "    \\hline"

    echo "\\end{tabular}"
    echo "\\caption{Výsledky testov pre profil $profile}"
    echo "\\label{tab:results-$fs}"
    echo "\\end{center}"
    echo "\\end{table}"
    echo

done
echo "%"
echo "% END Automatic results"
echo "%"
echo

