#!/bin/bash

replace_for_rust() {
    printf "Replacing uses of lolcat command in woof.sh and woof2.sh with lolcat-rs command\n"
    SCRIPT1=$(find ~/ -name woof.sh)
    SCRIPT2=$(find ~/ -name woof2.sh)

    eval "sed -i -e 's/lolcat/lolcat-rs/g' ${SCRIPT1}"
    eval "sed -i -e 's/lolcat/lolcat-rs/g' ${SCRIPT2}"

    echo "Substitutions completed."
    echo "All dependencies fulfilled."
}

pacman_cat() {
    read -p "Using pacman for install. Proceed? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    printf "Running: 'sudo pacman -S lolcat'\n"
    sudo pacman -S lolcat || eval "echo 'lolcat installation failed' && exit 1"
}

read -p "ATTENTION: this is the ARCH linux version of this setup script. Continue? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
printf "\nAttempting install of required package:\n\tascii-image-converter (author: TheZoraiz; https://github.com/TheZoraiz/ascii-image-converter)\n"

if [[ $(command -v ascii-image-converter) ]]; then
    echo "\nascii-image-converter already present on system. Proceeding..."
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
    printf "\nlolcat already present on system.\nChecking if rust substitutions needed.\n"

    if [[ $RUST_IMPLMNT ]]; then
        replace_for_rust
        exit 0
    fi
    echo "Substitutions not needed."
    echo "All dependencies fulfilled."
    exit 0
fi

if [[ $(command -v yay) ]]; then
    printf "\n'yay' detected. Attempting install of rust-based implementation of lolcat:\n\tlolcat-rs (author: Umang Raghuvanshi)\n"
    read -p "Proceed? (Y/N: use pacman instead of yay): " confirm && [[ $confirm == [yY] ]] || pacman_cat
    printf "Running: 'yay -S lolcat-rs'\n"
    yay -S lolcat-rs || eval "echo 'lolcat-rs installation failed' && exit 1"

    printf "Checking if rust substitutions needed.\n"
    if [[ $RUST_IMPLMNT ]]; then
        replace_for_rust
        exit 0
    fi
    echo "Substitutions not needed."
    echo "All dependencies fulfilled."
    exit 0
else
    pacman_cat
fi

echo "All dependencies fulfilled."
exit 0
