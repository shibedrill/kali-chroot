#!/bin/bash

set -e

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
echo "${BLUE}Kali Linux Chroot Uninstaller${NC}"
echo "${PURPLE}by shibedrill (Discord: Shibe Drill#9730)${NC}"
echo "Please let me know if you encounter a bug! I'm happy to help."
echo "This script will automatically uninstall the chroot that was generated by the kali-chroot script."
echo "${RED}WARNING: This is permanent! Your chroot and any data inside will be removed forever."
echo "Do you wish to continue? (y/N)${NC}"
# Take user consent to continue
read CONSENT
if [ "$CONSENT" != "y" ]
  then exit 1
fi
echo ""
sleep 1



# Find chroot path
# Breakdown since this next command is kinda weird:
# Path is equal to (whichever line contains "directory=", and then we remove "directory=". This gives us JUST the directory, in a readable format.)
CHROOTPATH=$(grep directory= /etc/schroot/chroot.d/kali.conf | sed 's/directory=//')
echo "${RED}Chroot found: "$CHROOTPATH". Proceeding with removal in 3 seconds. Press Ctrl + C to cancel."

sleep 1
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
sleep 1

echo "Uninstall is beginning.${NC}"
echo "Removing chroot dir..."
rm -r $CHROOTPATH
echo "Removing config file..."
rm /etc/schroot/chroot.d/kali.conf
echo "Removing alias..."
if [ -f /home/"$SUDO_USER"/.bash_aliases ] ; then
	# Perform inverted grep on alias to remove it from alias file
	grep -v "alias kali='xhost + && schroot -c kali -u root -d /root && schroot -e --all-sessions && xhost -'" /home/"$SUDO_USER"/.bash_aliases > tmpfile && mv tmpfile /home/"$SUDO_USER"/.bash_aliases
elif ! [ -f /home/"$SUDO_USER"/.bash_aliases ] ; then
	echo "Bash alias file not found. Make sure to remove your 'kali' alias from wherever you put it."
echo ""
sleep 1



echo "${PURPLE}Finished! Thank you for using kali-chroot!"
echo "If you had issues with your chroot, please let me know!$"

