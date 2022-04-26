#!/bin/bash

# Check if running as root and exit if not
if [ "$(id -u)" !=  "0" ]; then 
	echo "Please run as root"
  	exit 1
fi

# Set some colors
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'



# Welcome message
echo ""
echo -e "${BLUE}Kali Linux Chroot Generator${NC}"
echo -e "${PURPLE}by shibedrill (Discord: Shibe Drill#9730)${NC}"
echo "Please let me know if you encounter a bug! I'm happy to help."
echo "This script will automatically configure a Chroot environment in which to run many Kali Linux tools. Now please notice: Wireless tools will not work out of the box. However, most other tools will. Metasploit, password tools, GUI tools like Burp and Wireshark, and net tools like nmap will work out of the box."
echo ""
sleep 1



echo "Prerequesites: One of the following package managers:"
echo "apk, apt-get, dnf, zypper, pacman"
echo "You will also need internet access for this script to run."
echo -e "${RED}Warning: This might take up a lot of space! (>3gb)"
echo -e "Do you wish to continue? (y/N)${NC}"
# Take user consent to continue
read CONSENT
if [ "$CONSENT" != "y" ]
  then exit 1
fi
echo ""
sleep 1



echo -e "${BLUE}Step one: Install debootstrap and schroot if not installed.${NC}"
packagesNeeded='debootstrap wget sed xorg'
if [ -x "$(command -v apk)" ];       then apk add --no-cache $packagesNeeded
elif [ -x "$(command -v apt-get)" ]; then apt-get install $packagesNeeded
elif [ -x "$(command -v dnf)" ];     then dnf install $packagesNeeded
elif [ -x "$(command -v zypper)" ];  then zypper install $packagesNeeded
elif [ -x "$(command -v pacman)" ];  then pacman -S --needed $packagesNeeded
else echo -e "${RED}FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded${NC}">&2; fi
# TO-DO: Add error handling
echo -e "${PURPLE}debootstrap and schroot installed successfully!${NC}"
echo ""
sleep 1



echo -e "${BLUE}Step two: Generate chroot directory${NC}"
echo "Which directory do you want your chroot to be installed in? If you input a directory which does not exist yet, it will be created automatically."
echo "Default: /srv/chroot/kali"
# Read chroot path
read CHROOTPATH
if [ "$CHROOTPATH" = "" ]
  then CHROOTPATH=/srv/chroot/kali
fi
# Make directory if it doesn't exist
if ! [ -d "$CHROOTPATH" ]
  then mkdir "$CHROOTPATH"
  echo -e "${PURPLE}Directory created successfully!${NC}"
elif [ -d "$CHROOTPATH" ]
  then echo "Directory already exists. Continuing..."
fi
echo ""
sleep 1



# Begin bootstrapping
echo -e "${BLUE}Step three: Actually perform the bootstrap${NC}"
echo "Which architecture do you want to use?"
echo "Options: amd64, i386. Default: amd64"
# Read chroot architecture
read CHROOTARCH
if [ "$CHROOTARCH" = "" ]
  then CHROOTARCH=amd64
fi
KALIPACKAGES=kali-linux-core,zsh,apt-utils,dialog
echo "Would you like to install the kali-tools-top10 metapackage? (y/N)"
echo "This might cause the bootstrap to take longer."
# Read answer
read PACKAGEASK
if [ "$PACKAGEASK" = "y" ];
  then KALIPACKAGES+=",kali-tools-top10"
fi
echo -e "Beginning bootstrap. This might take a ${RED}WHILE!${NC}"
debootstrap --variant=buildd --include="$KALIPACKAGES" --arch="$CHROOTARCH" kali-rolling "$CHROOTPATH" http://http.kali.org/kali
echo -e "${PURPLE}Bootstrap finished!${NC}"
echo ""
sleep 1



# Debug step
echo -e "${BLUE}Step four: Debugging and configuring our new installation${NC}"

echo "Adding non-free and contrib sources to sources.list..."
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" > "$CHROOTPATH"/etc/apt/sources.list
echo "Adding sources: Done"

echo "Downloading Kali repo pubkey..."
wget https://archive.kali.org/archive-key.asc -O "$CHROOTPATH"/etc/apt/trusted.gpg.d/kali-archive-key.asc
echo "Adding pubkey: Done"

echo "Removing statoverride group Debian-exim..."
echo -e "${RED}Warning! This is a very hacky patch, and it might not work.${NC}"
if [ -f "$CHROOTPATH"/var/lib/dpkg/statoverride ] ; then
  # Perform inverted grep on statoverride file to remove debian-exim thing
  cp "$CHROOTPATH"/var/lib/dpkg/statoverride "$CHROOTPATH"/var/lib/dpkg/statoverride.bak
  grep -v "exim" "$CHROOTPATH"/var/lib/dpkg/statoverride.bak > tmpfile && mv tmpfile "$CHROOTPATH"/var/lib/dpkg/statoverride
fi
echo "Removing statoverride group: Done"

echo "Setting the chroot to use your display..."
echo "export DISPLAY=:0.0" >> "$CHROOTPATH"/root/.zshrc
echo "Setting display: Done"

echo "Searching for /etc/networks..."
if [ -d /etc/networks ] ; then
  echo "/etc/networks found, not patching."
  else
    echo "/etc/networks not found. Patching..."
    sed -i '/^networks$/s/^/#/' /etc/schroot/default/nssdatabases
    echo "Patching schroot config: Done"
fi

echo "Patching another schroot config to keep any created users inside the chroot..."
sed -i '/^passwd$/s/^/#/' /etc/schroot/default/nssdatabases
sed -i '/^shadow$/s/^/#/' /etc/schroot/default/nssdatabases
echo "Patching schroot config: Done"

echo "Creating our config file for schroot to reference..."
mkdir -p /etc/schroot/chroot.d
touch /etc/schroot/chroot.d/kali.conf
SCHROOTCFG=/etc/schroot/chroot.d/kali.conf
echo "[kali]" > "$SCHROOTCFG"
echo "description=Kali Linux apps running in chroot to prevent frankenDebian" >> "$SCHROOTCFG"
echo "root-users=root" >> "$SCHROOTCFG"
echo "type=directory" >> "$SCHROOTCFG"
echo "users=root,""$SUDO_USER" >> "$SCHROOTCFG"
echo "directory=""$CHROOTPATH" >> "$SCHROOTCFG"
echo "# Auto-generated by script kali-chroot." >> "$SCHROOTCFG"
echo "# Visit github.com/shibedrill/kali-chroot to learn more." >> "$SCHROOTCFG"
echo "Generating config file: Done"

echo "Setting aliases for host to use the chroot..."
if [ -f /home/"$SUDO_USER"/.bash_aliases ]
  then echo "alias kali='xhost + && schroot -c kali -u root -d /root && schroot -e --all-sessions && xhost -'" >> /home/"$SUDO_USER"/.bash_aliases && echo -e "${PURPLE}Alias added to your ~/.bash_aliases file. You can use your chroot by running the command ' kali '.${NC}"
  else echo -e "${RED}Bash alias file was not found in your home directory. Not auto-implementing." && echo -e "${PURPLE}Set the following alias in your profile or aliases file:" && echo -e "alias kali='xhost + && schroot -c kali -u root -d /root && schroot -e --all-sessions && xhost -'"
fi
echo ""
sleep 1



echo -e "Finished! Thank you for using kali-chroot!"

# Finished!
