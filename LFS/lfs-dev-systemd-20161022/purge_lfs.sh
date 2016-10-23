#!/bin/bash
sudo unlink /tools
sudo rm -r /mnt/lfs/*
sudo umount /mnt/lfs
sudo userdel lfs
sudo rm -r /home/lfs
unset LFS
