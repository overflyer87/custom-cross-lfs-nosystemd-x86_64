#!/bin/bash

#Reverse CLFS Installation until Temporary System

sudo userdel clfs
sudo groupdel clfs
sudo rm -rf /home/clfs/
sudo umount -f /mnt/clfs/home/
sudo rm -rf /mnt/clfs/home
sudo rm -rf /mnt/clfs/*
sudo umount -f /mnt/clfs
sudo rm -rf /mnt/clfs/
sudo unlink /cross-tools 
sudo unlink /tools