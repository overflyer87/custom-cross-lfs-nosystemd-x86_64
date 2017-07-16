#!/bin/bash

#Reverse CLFS Installation until Temporary System

sudo -f umount /mnt/clfs/dev/pts
sudo -f umount /mnt/clfs/dev
sudo -f umount /mnt/clfs/home
sudo -f umount /mnt/clfs/sys/firmware/efi/efivars
sudo -f umount /mnt/clfs/sys
sudo -f umount /mnt/clfs/run
sudo -f umount /mnt/clfs/proc
sudo userdel clfs
sudo groupdel clfs
sudo rm -r /home/clfs/
sudo rm -r /mnt/clfs/home
sudo rm -r /mnt/clfs/*
sudo umount /mnt/clfs/
sudo unlink /cross-tools 
sudo unlink /tools
