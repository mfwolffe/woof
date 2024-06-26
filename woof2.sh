#!/bin/bash

test_watch() {
    PICTCOUNT=$(ls /home/mfwolffe/Pictures/moby -l | wc -l)
    PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1);
    FILENAME="~/Pictures/moby/${PICNUM}.jpeg";
    AIC_CL_FLAGS="${FILENAME} $@";
    COMMAND="ascii-image-converter ${AIC_CL_FLAGS}";

    echo "run: $COMMAND"
    eval "$COMMAND"

    # if [ $PRIDE_FLAG -eq 1 ]; then
    #     eval "$COMMAND | lolcat-rs ";
    #     else
    #     eval "$COMMAND";
    # fi
}

export -f test_watch
watch --color -x bash -c "test_watch $@"
# watch --color -x /bin/zsh -c "script -q -c 'ascii-image-converter ~/Pictures/moby/5.jpeg --color'"
