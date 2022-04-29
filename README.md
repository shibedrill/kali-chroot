# kali-chroot v0.5.0
Quickly and easily create a Chroot environment in which to run containerized Kali tools, without screwing up your libraries on your host system.

Feel free to contribute!

### Important:
This is still in the testing phase. Please be careful!
Please let me know if you would like to help me test this script. I'm always looking for a helping hand.

Summary:  
This script utilizes schroot and debootstrap to create a chroot environment on your system. It installs the kali-core metapackage, alongside zsh, in a user-specified directory. Then it patches all the issues I've encountered thus far, in order to grant you a functional installation. You are also given the option to install the ` kali-tools-top10 ` metapackage (which contains Metasploit and all the other goodies) during the bootstrap.

Notice:  
This script will install the Xorg package, if it is not already installed. This is to allow GUI applications to run on the same display server. If you use something other than X (such as Wayland), this script WILL NOT replace your default server. X is composited into Wayland in this scenario.

Features:  
- Fully automated, with very minimal user action
- Works on distros with apk, apt, dnf, zypper, or pacman as their package managers
- Patches package/distro issues that occur
- Configures both chroot and host to use the same X display
- Generates and tries to implement an alias that the user can use to quickly access the chroot
- Provides uninstaller script to remove chroot if needed

Issues:  
 - Hardware based tools will not work (aircrack-ng, wifite, et cetera)
 - User might get the following error while updating: ` syntax error: unknown group 'Debian-exim' in statoverride file `
 
Possible fixes:  
- Use symlink files between the chroot and host to allow access to wireless adapters
- Open ` /var/lib/dpkg/statoverride ` in a text editor and remove the line containing ` Debian-exim ` (ensure to leave no empty lines)

Requisites:  
- One of the following package managers:
    - apk
    - apt-get
    - dnf
    - zypper
    - pacman
- An internet connection
- ~3 gb of storage space for the base system
- BASH shell installed

Please help me grow this project by testing it on other systems!  
Tested systems:  
- Ubuntu
    - Ubuntu 20.04
- Ubuntu-based
    - KDE Neon 5.24
- Arch-based
    - EndeavourOS Apollo 22

To-do:  
- Figure out how to patch or prevent the errors while bootstrapping, as opposed to fixing them after the bootstrap
- Add error handling
- Test on more distributuions

## Why would I use this script?
I'm going to be honest here. I've tried running Kali Linux bare-metal. I have. It's never been fun. Even installing something as simple as Discord results in dependency issues, and ` apt autoremove ` would uninstall it. Kali Linux with KDE has broken Discover backends. It's just a hot mess, and I don't trust it enough to run it as my primary operating system. Virtual machines are far too much overhead, and I don't know enough about Docker to get it working. So the solution I turned to was simply installing the tools from Kali.

I commonly use Ubuntu-based distros, which means I normally have the capability to run Debian tools bare-metal. However, that doesn't mean I've had a fun time installing each and every Kali tool on its own. Even if you try using the metapackages, there's too many conflicts between glibc versions to let it do it automatically. Chances are you'll end up having to install a few tools from separate sources.

As such, I turned to this concept: running Kali in a chroot environment. It's no different from a real Kali installation at the base level, and all the libraries are where they should be. You don't get the overhead of a virtual machine, since it runs natively in the Linux kernel and filesystem. The files are all right there, so it's easy to copy files to and from it. There's no futzing about with Docker images, which is good for people who aren't experienced with containers. And most Kali tools are CLI-based, so it didn't matter that graphical apps didn't work when I created the first iteration of this script (Although I've since made tweaks to allow GUI apps to run on the host display). In short, you have all the benefits of running bare-metal, with none of the drawbacks other than complexity. And that's exactly what this script aims to solve.

If you're an amateur Linux enthusiast looking to get into pentesting or offsec, I encourage you to try out this script. It'll make learning a lot easier for you.
