#!/bin/bash

replace_for_rust() {
    printf "Replacing uses of lolcat command in woof.sh and woof2.sh with lolcat-rs command\n"
    SCRIPT1=$(find ~/ -name woof.sh)
    SCRIPT2=$(find ~/ -name woof2.sh)

    eval "sed -i -e 's/lolcat/lolcat-rs/g' ${SCRIPT1}"
    eval "sed -i -e 's/lolcat/lolcat-rs/g' ${SCRIPT2}"

    echo "Substitutions completed."
}

pacman_cat() {
    read -p "Using pacman for install. Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    printf "Running: 'sudo pacman -S lolcat'\n"
    sudo pacman -S lolcat || eval "echo 'lolcat installation failed' && exit 1"
}

rename_sequential() {
    printf "\nwoof.sh requires files to be named sequentially.\n"
    printf "Running:\n"
    printf "\t\"num=1; for i in *; do mv \"\$i\" \"\$(printf '%d' \$num).jpeg\"; ((num++)); done"
    num=1; for i in *; do mv "$i" "$(printf '%d' $num).jpeg"; ((num++)); done
}


add_archives() {
    printf "All dependencies fulfilled.\n\n"
    # TODO mfwolffe maybe put this back into the overall setup.sh 
    read -p "Proceed to archive selection? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    printf "PUPPER SELECTION:\n"
    printf "\tBy default, woof uses photos of Moby the border-aussie; the archive is curled from a\n"
    printf "\t'public' google drive folder. Other pups' archives may be selected too. Options are:\n" 
    printf "\t\tBella the Bubbly. Other pups coming soon.\n\n"

    # TODO @mfwolffe once you have real ID's for the other pups, 
    # uncomment and finish this multiple selection approach
    #
    # while true; do
    #     read -p "Do your Choice: [1] [2] [3] [4] [5] [A]bort: " -a pup_array
    #     for pup in "${pup_array[@]}"; do
    #         case "$pup" in
    #             [1]* ) echo "$pup selected";;
    #             [2]* ) echo "$pup selected";;
    #             [3]* ) echo "$pup selected";;
    #             [4]* ) echo "$pup selected";;
    #             [Ee]* ) echo "Aborting"; exit;;
    #             * ) echo "Invalid choice: $pup";;
    #         esac
    #     done
    # done

    PUPID="bad_id"
    PUPNAME="bad_name"

    while true; do
        read -p "Select a pup: [1] - Moby, [2] - Bella, [A]bort: " pup
        case "$pup" in
            [1]* ) echo Moby selected; PUPID="1460H0ABkVSNwNPRWltsvDb1gufwD9Zpy"; PUPNAME="moby"; break;;
            [2]* ) echo Bella selected; PUPID="1M-xlBm1ksak-SChqDVGxSKH_JDW_Hzrv"; PUPNAME="bella"; break;;
            # [3]* ) echo Tilly selected; PUPID=""; break;;
            # [4]* ) echo Twinky selected; PUPID=""; break;;
            # [5]* ) echo Dachshunds selected; PUPID="" ;;
            [Aa]* ) echo "Aborting"; exit 0;;
            * ) echo "Invalid choice: $pup" 
        esac
    done

    WFSRC_DIR=$(find ~/ -type d -name woof)
    ARCH_DIR="${WFSRC_DIR}/src/archive"

    if [ ! -d "$ARCH_DIR" ]; then
        mkdir "$ARCH_DIR"
    fi

    if [ -f "$ARCH_DIR/$PUPNAME.tar.gz" ]; then
        echo "Archive already exists"
        # TODO @mfwolffe option to remove & replace
    else
        printf "\nArchive will now be curled from google drive and stored in:\n"
        printf "\t$ARCH_DIR \n"
        read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

        printf "\nRunning:\n"
        printf "\tcurl \"https://drive.usercontent.google.com/download?id={${PUPID}}&confirm=xxx\" -o \"$ARCH_DIR/$PUPNAME.tar.gz\""
        curl "https://drive.usercontent.google.com/download?id={${PUPID}}&confirm=xxx" -o "$ARCH_DIR/$PUPNAME.tar.gz" || exit 1
        printf "Archive added successfully.\n"
    fi

    if [ ! -d "$ARCH_DIR/$PUPNAME" ]; then
        read -p "Unzip archive? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
        printf "\nRunning:\n"
        printf "\ttar xvzf \"$ARCH_DIR/$PUPNAME.tar.gz\" -C $ARCH_DIR\n"
        tar xvzf "$ARCH_DIR/$PUPNAME.tar.gz" -C $ARCH_DIR || exit 1
        printf "Archive unzipped\n"
    else
        printf "Archive already unzipped\n"
    fi

    exit 0
}

printf "\nAttempting install of required package:\n\tascii-image-converter (author: TheZoraiz; https://github.com/TheZoraiz/ascii-image-converter)\n\n"
if [[ $(command -v ascii-image-converter) ]]; then
    echo "ascii-image-converter already present on system."
    read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
else
    printf "Running: 'git clone https://aur.archlinux.org/ascii-image-converter-git.git ~/ascii-image-converter-git'\n"
    read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    git clone https://aur.archlinux.org/ascii-image-converter-git.git ~/ascii-image-converter.git || eval "echo 'Cloning failed' && exit 1"
    cd ~/ascii-image-converter-git/
    printf "Building package: 'makepkg -si'\n" || eval "echo 'Build failed' && exit 1"
    makepkg -si
    cd -
    echo "Successfully installed ascii-image-converter"
fi

printf "\nAttempting install of required package:\n\tlolcat\n"

# some installations might not symlink lolcat to lolcat-rs
# in this case, replace all instances of 'lolcat' with
# 'lolcat-rs' within the two woof scripts 
RUST_IMPLMNT=$(command -v lolcat-rs)

if [[ $(command -v lolcat) || $RUST_IMPLMNT ]]; then
    printf "\nlolcat already present on system.\n"
    read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    printf "Checking if rust substitutions needed.\n\n"

    if [[ $RUST_IMPLMNT ]]; then
        replace_for_rust
        add_archives
    fi
    printf "Substitutions not needed.\n"
    add_archives
fi

if [[ $(command -v yay) ]]; then
    printf "\n'yay' detected. Attempting install of rust-based implementation of lolcat:\n\tlolcat-rs (author: Umang Raghuvanshi)\n"
    read -p "Proceed? (Y: proceed with yay; N: use pacman instead of yay): " confirm && [[ $confirm == [yY] ]] || pacman_cat
    printf "Running: 'yay -S lolcat-rs'\n"
    yay -S lolcat-rs || eval "echo 'lolcat-rs installation failed' && exit 1"

    printf "Checking if rust substitutions needed.\n"
    if [[ $RUST_IMPLMNT ]]; then
        replace_for_rust
    fi
    echo "Substitutions not needed."
    add_archives
else
    pacman_cat
    add_archives
fi
