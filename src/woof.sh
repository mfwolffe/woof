#!/bin/bash

WFSRC_DIR=$(find ~/ -type d -name woof)
ARCH_DIR="${WFSRC_DIR}/src/archive"

DOGGOSDIR="${ARCH_DIR}/moby"

# TODO: long args - debug, pride, what else?
OPTSTRING=":bcdghl:npsxw:D"

# flags for CLI option validation
COLOR_FLAG=0
PRIDE_FLAG=0
DITHER_FLAG=0
DIALUP_FLAG=0
BRAILLE_FLAG=0

# how long to wait before rerunning
# command if opting for indefinite
INDF_DELAY=0

AIC_CL_FLAGS=""

usage()
{
    echo "This utility picks a random photo of Moby the border-aussie (or your pup/pet of choice) and generates ascii art from it."
    echo "USAGE: woof [options]"
    echo "OPTIONS:"
    echo "  -c       |  color mode"
    echo "  -b       |  braille mode"
    echo "  -n       |  invert colors"
    echo "  -p       |  celebrate pride!"
    echo "  -h       |  show program usage"
    echo "  -g       |  background-color mode"
    echo "  -x       |  use wider range of characters"
    echo "  -d       |  dither mode (requires -b passed)"
    echo "  -D       |  dialup mode (load image line by line)"
    echo "  -s       |  show installed pup archives for use with -w flag"
    echo "  -l <N>   |  repeat this command indefinitely every N seconds"
    echo "  -w <pup> |  Choose a dog/pet from available archives. Defaults to moby"
    echo
    exit $1
}

show_pups() {
    echo "Available pups:"
    cd "$ARCH_DIR"
    ls -d */ | awk -F'/' '{print $1}'
    # printf "Select a number from the list below\n"
    # select d in */; do test -n "$d" && break; echo "ERROR: No such archive"; done
    # DOGGOSDIR="${ARCH_DIR}/${d}"
    # echo $DOGGOSDIR
}

while getopts ${OPTSTRING} opt; do
    case ${opt} in
        b)
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --braille"
            BRAILLE_FLAG=1
            ;;
        c)
            if [ $PRIDE_FLAG -eq 1 ]; then
                echo "Incompatible flag combination: -p & -c"
                exit 1;
            fi
            COLOR_FLAG=1
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --color"
            ;;
        d)
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --dither"
            DITHER_FLAG=1
            ;;
        D)
            DIALUP_FLAG=1
            ;;
        g)
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --color-bg"
            ;;
        h)
            usage 0
            ;;
        l)
            INDF_DELAY=$OPTARG
            ;;
        n)
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --negative"
            ;;
        p)
            if [ $COLOR_FLAG -eq 1 ]; then
                echo "Incompatible flag combination: -c & -p"
                exit 1;
            fi
            PRIDE_FLAG=1
            ;;
        s) 
            show_pups
            exit 0
            ;;
        w)
            DOGGOSDIR="$ARCH_DIR/$OPTARG"
            ;;
        x)
            AIC_CL_FLAGS="${AIC_CL_FLAGS} --complex"
            ;;
        ?)
            echo "Invalid option: \"-${OPTARG}\""
            echo
            usage 1
            ;;
    esac
done

PICTCOUNT=$(ls $DOGGOSDIR -l | wc -l)

perpetual_pup() {
    PICTCOUNT=$(ls "$1" -l | wc -l)
    echo $PICTCOUNT
    PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1);
    FILENAME="${1}/${PICNUM}.jpeg";
    COMMAND="ascii-image-converter ${FILENAME} ${AIC_CL_FLAGS}"
    printf "\nRunning:\n\t${COMMAND}\n"
    eval "${COMMAND}"
}

if [ $DITHER_FLAG -eq 1 -a $BRAILLE_FLAG -eq 0 ]; then
    echo "ERROR: image dithering is only reserved for -b flag"
    usage 1
fi

if [ $DIALUP_FLAG -eq 1 -a $PRIDE_FLAG -eq 0 ]; then
    echo "ERROR: dialup is reserved for use with pride mode"
    usage 1
fi

PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1)
FILENAME="${DOGGOSDIR}/${PICNUM}.jpeg"

if [ ! $INDF_DELAY -eq 0 ]; then
    echo "dude we are here"
    export -f perpetual_pup
    watch --color -x bash -c "perpetual_pup $DOGGOSDIR"
    exit 0
fiC

AIC_CL_FLAGS="${FILENAME} ${AIC_CL_FLAGS}"
COMMAND="ascii-image-converter ${AIC_CL_FLAGS}"

if [ $PRIDE_FLAG -eq 1 ]; then
    PIPE_ARGS=$([ $DIALUP_FLAG -eq 1 ] && echo "-D -f 0.4" || echo "-f 0.4")
    eval "$COMMAND | lolcat ${PIPE_ARGS}"
    exit 0
fi

eval "$COMMAND" || echo "Script failed. check file names/paths, and/or flags"

# echo Running: $COMMAND
# echo $INDF_DELAY

# if [ ! $INDF_DELAY -eq 0 ]; then
#     trap 'echo; echo "SIGINT received...exiting"; exit 0' INT
#     while true
#     do
#         # clear;
#         PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1);
#         FILENAME="${DOGGOSDIR}/${PICNUM}.jpeg";
#         AIC_CL_FLAGS="${FILENAME} ${AIC_CL_FLAGS}";
#         COMMAND="ascii-image-converter ${AIC_CL_FLAGS}";

#         if [ $PRIDE_FLAG -eq 1 ]; then
#             eval "$COMMAND | lolcat";
#             else
#             eval "$COMMAND";
#         fi
#         eval "sleep 1";
#     done
# fi
