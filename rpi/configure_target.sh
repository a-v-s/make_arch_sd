#!/usr/bin/bash

echo Configure target script

# Initialise and populate keyring
pacman-key --init
pacman-key --populate archlinuxarm

# Enable parallel downloads
sed -i 's/#ParallelDownloads/ParallelDownloads/g' /etc/pacman.conf 

# Download and install updates
pacman --noconfirm  -Suy


