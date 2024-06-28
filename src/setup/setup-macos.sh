#!/bin/bash

# TODO @mfwolffe make this behave similarly to arch version

install_brew() {
  echo "Package ascii-image-converter is required to run woof, which can be installed with Homebrew (https://brew.sh/)"
  read -p "Attempt to install Homebrew? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
  echo "ensure you have completed the section labeled "Next Steps" shown in your terminal post-installation of Homebrew"
}

make_aliases() {
  printf "\n# Woof aliases:\n" >> ~/.zshrc
  echo 'alias woof="$1/woof.sh"' >> ~/.zshrc
  echo 'alias woof-proud="$1/woof.sh -p"' >> ~/.zshrc
} 

printf "\nInstalling required package:\n\tascii-image-converter (author: TheZoraiz; https://github.com/TheZoraiz/ascii-image-converter)\n"
read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
echo "running 'brew install TheZoraiz/ascii-image-converter/ascii-image-converter'"
brew install TheZoraiz/ascii-image-converter/ascii-image-converter && printf "\nSuccessfully installed ascii-image-converter ✅\n" || install_brew

printf "\nInstalling required package:\n\tlolcat (author: @busyloop; https://github.com/busyloop/lolcat)"
read -p "Proceed? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
echo "running 'brew install lolcat'"
brew install lolcat && printf "\nSuccessfully installed lolcat ✅\n" || eval 'echo "Installation failed" ; exit 1'

printf "\nSetup complete.\n\t"
read -p "Add aliases for woof and woof-proud to .zshrc? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || eval 'echo "Exiting setup" && exit 0'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" && make_aliases $SCRIPT_DIR || eval "echo 'Alias creation failed' && exit 1"
printf "\nAliases created. Exiting setup.\n"
read -p "Show tail of ~/.zshrc to confirm? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 0
tail ~/.zshrc

exit 0


