#!/bin/bash

# tlFileLog
# Usage: tlFileLog log_file section variable value
# Example: tlFileLog /tmp/log disk-tests total-time 15s

function tlFileLog()
{
    fileName=$1
    section=$2
    variable=$3
    value=$4
    
    # Create file if not exists
    touch "$fileName"

    # Create tempfile
    tempFile=`mktemp`

    # File exists? (wrong permissions, etc)
    if ! test -e "$fileName"
    then
        rlFail "Log file '$fileName' does not exists"
        return 1
    fi

    # Does this file contains this section?
    grep "^\[$section\]$" "$fileName" >/dev/null 2>/dev/null

    if [ $? -eq 0 ]
    then
        # Find this file and work with it

        # Backup IFS
        IFS_BAK=$IFS
        IFS=$'\n'
        
        # Some helpers
        inSection=false
        out=""
        variableFound=false
        
        # Loop!
        for line in `cat $fileName`
        do
            # Section delimiter?
            echo $line | grep "^\[.*\]$" 2>/dev/null >/dev/null
            if [ $? -eq 0 ]
            then
                # If we were in section but no variable found
                if [ $inSection = "true" ] && [ $variableFound = "false" ]
                then
                    # Add this new variable to section
                    echo "${variable}: $value" >> $tempFile
                fi
                inSection=false
                variableFound=false
            fi

            # Work with data, if we are in correct section
            if [ $inSection = true ]
            then
                # Are we on correct line?
                echo "$line" | grep "^$variable: " > /dev/null 2>/dev/null
                if [ $? -eq 0 ]
                then
                    line="$variable: $value"
                    variableFound=true
                fi
            fi

            # In needed section?
            echo $line | grep "^\[$section\]$" 2>/dev/null >/dev/null
            test $? -eq 0 && inSection=true

            # Write line to file
            echo $line >> $tempFile
        done

        # Restore IFS
        IFS=$IFS_BAK
        
        # It was the last section and the variable was not found
        if [ $inSection = "true" ] && [ $variableFound = "false" ]
        then
            # Add this new variable to section
            echo "${variable}: $value" >> $tempFile
        fi
        # Change log file
        mv -f "$tempFile" "$fileName"

    else
        # Add it
        echo "[$section]" >> "$fileName"
        echo "$variable: $value" >> "$fileName"
    fi
}
