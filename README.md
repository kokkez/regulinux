# REGULINUX

![Regulinux Logo](/logo.png)

Regulinux is a debian-like linux post-installation standardizer.

## Introduction

Given the lack of consistency in Debian and Ubuntu installations across various server providers, there emerged a necessity for a standardized Linux installation applicable to all type of servers, were them dedis, vm or containers.

The development of this software aims to facilitate uniform Debian and Ubuntu server installations, independent of the hosting provider.

## Features

1. Customize Linux as a meta-distribution by **adding and removing components**.

2. Install a **personalized list of packages** tailored to your needs.

3. **Manages variations** among vendors to achieve a more consistent experience.

## Installation

To install this software, copy both the installation file, `easy-regulinux.sh`, and your `.ssh` folder (containing your private key for subsequent connections) to your server. This can be achieved through any SFTP and FTP software like WinSCP.

Run the installation file and wait for the completion of the Regulinux setup process.

```bash
# Installs Regulinux
./easy-regulinux.sh
```

After installation, the Regulinux menu will display, informing the sysadmin of available actions.

## Usage

The menu will appear automatically after installation, but it can be printed at any time by using its dedicated command.

```bash
# Prints the menu
os
```

```bash
# Example of menu on a debian-9
2023-11-14 10:50:00 +0100 :: debian-9 (stretch) x86_64 :: /root/linux.debian-9.stretch.x86_64
[ . One time actions ---------------------------------------------- (in recommended order) -- ]
  . root        setup private key, sources.list, shell, SSH port
  . deps        run prepare, check dependencies, update the base system, setup firewall
[ . Standalone utilities ---------------------------------------- (in no particular order) -- ]
  . upgrade     apt full upgrading of the system
  . addswap     add a file to be used as SWAP memory, default 512M
  . password    print a random pw: $1: length (6 to 32, 24), $2: flag strong
  . bench       basic benchmark to get OS info
  . iotest      perform the classic I/O test on the server
[ . Main applications --------------------------------------------- (in recommended order) -- ]
  . mailserver  full mailserver with postfix, dovecot & aliases
  . dbserver    the DB server MariaDB, root pw stored in ~/.my.cnf
  . webserver   webserver apache2 or nginx, with php, selfsigned cert, adminer
[ . Target system ----------------------------------------------- (in no particular order) -- ]
  . dns         bind9 DNS server with some related utilities
  . ispconfig   historical Control Panel, with support at howtoforge.com
[ . Others applications ----------------------------------- (depends on main applications) -- ]
  . firewall    to setup the firewall, via iptables, v4 and v6
  . dumpdb      to backup all databases, or the one given in $1
  . roundcube   full featured imap web client
  . nextcloud   on-premises file share and collaboration platform
  . acme        shell script for Let's Encrypt free SSL certificates
[ ------------------------------------------------------------------------------------------- ]
```
