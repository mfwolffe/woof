#!/bin/bash

# TODO: long args - debug, pride, what else?
OPTSTRING=":bcdghl:npx"
DOGGOSDIR="/home/mfwolffe/Pictures/moby"
PICTCOUNT=$(ls /home/mfwolffe/Pictures/moby -l | wc -l)

# flags for CLI option validation
COLOR_FLAG=0
PRIDE_FLAG=0
DITHER_FLAG=0
BRAILLE_FLAG=0

# how long to wait before rerunning
# command if opting for indefinite
INDF_DELAY=0

AIC_CL_FLAGS=""

usage()
{
    echo "This utility picks a random photo of Moby the border-aussie and generates ascii art from it."
    echo "USAGE: woof [options]"
    echo "  -c     |  color mode"
    echo "  -b     |  braille mode"
    echo "  -n     |  invert colors"
    echo "  -p     |  celebrate pride!"
    echo "  -h     |  show program usage"
    echo "  -g     |  background-color mode"
    echo "  -x     |  use wider range of characters"
    echo "  -d     |  dither mode (requires -b passed)"
    echo "  -l <N> |  repeat this command indefinitely every N seconds"
    echo
    exit $1
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

if [ $DITHER_FLAG -eq 1 -a $BRAILLE_FLAG -eq 0 ]; then
    echo "ERROR: image dithering is only reserved for -b flag"
    usage 1
fi

PICNUM=$(shuf -i 1-${PICTCOUNT} -n 1)
FILENAME="${DOGGOSDIR}/${PICNUM}.jpeg"

if [ ! $INDF_DELAY -eq 0 ]; then
    echo "executing woof2.sh ${AIC_CL_FLAGS}"
    /home/mfwolffe/Scripts/woof/woof2.sh "$AIC_CL_FLAGS"
    # watch --color 'unbuffer ~/Scripts/woof2.sh'
    exit 0
fi

AIC_CL_FLAGS="${FILENAME} ${AIC_CL_FLAGS}"
COMMAND="ascii-image-converter ${AIC_CL_FLAGS}"

if [ $PRIDE_FLAG -eq 1 ]; then
    eval "$COMMAND | lolcat-rs "
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
#             eval "$COMMAND | lolcat-rs ";
#             else
#             eval "$COMMAND";
#         fi
#         eval "sleep 1";
#     done
# fi
