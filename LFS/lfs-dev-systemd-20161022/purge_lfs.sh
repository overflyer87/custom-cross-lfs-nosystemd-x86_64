#!/bin/bash
sudo unlink /tools
sudo unlink /cross-tools
sudo rm -r /mnt/clfs/*
sudo umount /mnt/clfs
sudo userdel clfs
sudo rm -r /home/clfs
unset CLFS
