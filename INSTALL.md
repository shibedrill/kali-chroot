# Installation

Installation via this script is very simple.
The only requirements are the script, internet access, BASH, 4gb of free space, and a supported package manager.

1. Download this script and run it with Sudo. Your command should look like this:
   ` sudo bash ./kali-chroot.sh `
2. Supply all the info the tool asks for.
3. If the script can't find your alias file, place the generated alias in whichever location you desire.  
   Simple as that! You can now use the command ` kali ` to enter your Chroot. Be sure to install some Kali metapackages first, as the default install doesn't contain anything other than the base system.  
   
   # Uninstall
   
   I have provided an uninstaller script for your convenience! This will remove the chroot and its config file.
   Additionally, this script will attempt to remove the alias it created and implemented.
4. Run the uninstall script with Sudo. Your command should look like this:
   ` sudo bash ./uninstall.sh `
5. If the script fails to locate the alias for the chroot, it will notify you, and you must remove it manually.
   That's all! Your chroot and its config files have been deleted.
   
   ### That's all!
   
   If you have ANY issues with installation, please please please let me know. I will be more than happy to try to fix it with you.
