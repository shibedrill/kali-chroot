# kali-chroot v0.1.0
Quickly and easily create a Chroot environment in which to run containerized Kali tools, without screwing up your libraries on your host system.

Summary:
This script utilizes schroot and debootstrap to create a chroot environment on your system. It installs the kali-core package, alongside ZSH, in a user-specified directory. Then it patches all the issues I've encountered thus far in order to grant you a functional installation.

Feel free to contribute!

Features:
- Fully automated, with very minimal user action
- Patches package/distro issues that occur
- Configures both chroot and host to use the same X display
- Generates an alias that the user can use to quickly access the chroot

Issues:
 - Hardware based tools will not work (aircrack-ng, wifite, et cetera)
 - Some patches might not work
 
Possible fixes:
- Use symlink files between the chroot and host to allow access to wireless adapters
- Use better text editing for patching

Requisites:
- APT (you should be running a Debian-based system already)
- An internet connection
- ~3 gb of storage space for the base system

To-do:
- Allow the script to check for the system package manager and use it to install schroot, wget, and debootstrap
- Enable the script to automatically install aliases on the host system
- Figure out how to patch or prevent the errors while bootstrapping, as opposed to fixing them after the bootstrap
- Add error handling
