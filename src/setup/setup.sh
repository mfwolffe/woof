#!/bin/bash

COL=$(tput cols)
welcome_msg="~~~~~~~~~~~~~ Installing prerequisites for woof ~~~~~~~~~~~~~"
attribution="author: mfwolffe (https://github.com/mfwolffe)"

center_text() {
    printf "\n%*s\n" $(((${#1}+$COL)/2)) "$1"
}

center_text "$welcome_msg"
center_text "$attribution"

printf "\nNOTE:"
printf "\n\tThis script is really only intended for me, myself, and I at the moment, as reminding"
printf "\n\tmyself of/performing the (albeit short) setup for each OS I use is rather annoying."
printf "\n\tI really only use arch and MacOS at the moment, so this script only covers those bases.\n"

printf "\nDetecting Operating System\n"

if [ -f "/etc/arch-release" ]; then
    printf "\nATTENTION:\n\tIt has been detected your machine is an arch-based linux distribution.\n"
    read -p "Proceed with arch setup? (Y/N): " confirm && [[ $confirm == [yY] ]] || eval "echo 'OS detection failure' && exit 1"

    SETUP=$(find ~/ -name setup-arch.sh)
    /bin/bash "$SETUP" && echo Setup Complete || echo Setup failed $?
    # TODO @mfwolffe dig through your memory wrt how to exit w/ status of invoked script... 
    exit $?
fi

if [[ $OSTYPE = "darwin"* ]]; then 
    printf "\nATTENTION:\n\tIt has been detected your machine is running MacOS.\n"
    read -p "Proceed with MacOS setup? (Y/N): " confirm && [[ $confirm == [yY] ]] || eval "echo 'OS detection failure' && exit 1"

    SETUP=$(find ~/ -name setup-macos.sh)
    /bin/bash "$SETUP"  && echo Setup Complete || echo Setup failed
    # see above todo 
    exit $? 
fi
