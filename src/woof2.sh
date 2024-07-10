#!/bin/bash

# SEEME @mfwolffe there are several issues with the "indefinite" flag
#                 in no particular order, they are:
#                   1) if a user wants to output with color, even when running
#                      as `bash -c ...` it appears to default to sh 
#                   2) braille mode is not working now. And that's my fault.
#                   3)  

test_watch() {
    PICTCOUNT=$(ls "$1" -l | wc -l)
    PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1);
    FILENAME="${1}/${PICNUM}.jpeg";
    AIC_CL_FLAGS="${FILENAME} $2"
    COMMAND="ascii-image-converter ${AIC_CL_FLAGS}";

    echo "run: $COMMAND"
    eval "$COMMAND"
}

export -f test_watch
watch --color -x bash -c "test_watch $@"
# watch --color -x /bin/zsh -c "script -q -c 'ascii-image-converter ~/Pictures/moby/5.jpeg --color'"
