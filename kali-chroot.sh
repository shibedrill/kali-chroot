#!/bin/bash

set -e

# Check if running as root and exit if not
if [ "$(id -u)" !=  "0" ]; then 
	echo "Please run as root"
  	exit 1
fi

# Welcome message
echo "Kali Linux Chroot Generator"
echo "by shibedrill (Discord: Shibe Drill#9730)"
echo "Please let me know if you encounter a bug! I'm happy to help."
echo "This script will automatically configure a Chroot environment in which to run many Kali Linux tools. Now please notice: Wireless tools will not work out of the box. However, most other tools will. Metasploit, password tools, GUI tools like Burp and Wireshark, and net tools like nmap will work out of the box."
echo ""
echo "Prerequesites: One of the following package managers:"
echo "apk, apt-get, dnf, zypper, pacman"
echo "You will also need internet access for this script to run."
echo "Warning: This might take up a lot of space! (>3gb)"
echo "Do you wish to continue? (y/n)"
read CONSENT
if [ "$CONSENT" != "y" ]
  then exit 1
fi
echo ""

echo "Step one: Install debootstrap and schroot if not installed."
packagesNeeded='debootstrap wget sed'
if [ -x "$(command -v apk)" ];       then apk add --no-cache $packagesNeeded
elif [ -x "$(command -v apt-get)" ]; then apt-get install $packagesNeeded
elif [ -x "$(command -v dnf)" ];     then dnf install $packagesNeeded
elif [ -x "$(command -v zypper)" ];  then zypper install $packagesNeeded
elif [ -x "$(command -v pacman)" ];  then pacman -S $packagesNeeded
else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; fi
# TO-DO: Add error handling
echo "debootstrap and schroot installed successfully!"
echo ""

echo "Step two: Generate chroot directory"
echo "Which directory do you want your chroot to be installed in? If you input a directory which does not exist yet, it will be created automatically."
echo "Default: /srv/chroot/kali"
# Read chroot path
read CHROOTPATH
if [ "$CHROOTPATH" = "" ]
  then CHROOTPATH=/srv/chroot/kali
fi
# Make directory if it doesn't exist
[ -d "$CHROOTPATH" ] || mkdir "$CHROOTPATH"
echo "Directory created successfully!"
echo ""

# Begin bootstrapping
echo "Step three: Actually perform the bootstrap"
echo "Which architecture do you want to use?"
echo "Options: amd64, i386. Default: amd64"
# Read chroot architecture
read CHROOTARCH
if [ "$CHROOTARCH" = "" ]
  then CHROOTARCH=amd64
fi
echo "Beginning bootstrap. This might take a WHILE!"
debootstrap --variant=buildd --include=kali-linux-core,zsh --arch="$CHROOTARCH" kali-rolling "$CHROOTPATH" http://http.kali.org/kali
echo "Bootstrap finished!"
echo ""

# Debug step
echo "Step four: Debugging and configuring our new installation"
echo "Adding non-free and contrib sources to sources.list..."
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" > "$CHROOTPATH"/etc/apt/sources.list
echo "Done"
echo "Downloading Kali repo pubkey..."
wget https://archive.kali.org/archive-key.asc -O "$CHROOTPATH"/etc/apt/trusted.gpg.d/kali-archive-key.asc
echo "Done"
echo "Removing statoverride group Debian-exim..."
echo "Warning! This is a very hacky patch, and it might not work."
cp "$CHROOTPATH"/var/lib/dpkg/statoverride "$CHROOTPATH"/var/lib/dpkg/statoverride.bak
sed -i '1d' "$CHROOTPATH"/var/lib/dpkg/statoverride
echo "Done"
echo "Setting the chroot to use your display..."
echo "export DISPLAY=:0.0" >> "$CHROOTPATH"/root/.zshrc
echo "Done"
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
echo "Setting aliases for host to use the chroot..."
if [ /home/"$SUDO_USER"/.bash_aliases ]
  then echo "alias kali='xhost + && schroot -c kali -u root -d /root && schroot -e --all-sessions && xhost -'" >> /home/"$SUDO_USER"/.bash_aliases
  else echo "Bash alias file was not found in your home directory. Not auto-implementing." && echo "Set the following alias in your profile or aliases file:" && echo "alias kali='xhost + && schroot -c kali -u root -d /root && schroot -e --all-sessions && xhost -'"
echo ""

echo "Finished! Thank you for using kali-chroot!"

# Finished!
