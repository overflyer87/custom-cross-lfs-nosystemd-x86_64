#!/bin/bash

echo " "
echo "Execute this script if you want NO checks or tests whatsoever"
echo "Execute this script inside the path where all the clfs_*.sh scripts are"
echo " "

sed -i 's/checkBuiltPackage/#checkBuiltPackage/' ../clfs_*.sh 
sed -i 's/function #checkBuiltPackage/function checkBuiltPackage/' ../clfs_*.sh 
sed -i 's/make check/#make check/' ../clfs_*.sh 
sed -i 's/make -k check/#make -k check/' ../clfs_*.sh  
sed -i 's/make test/#make test/' ../clfs_*.sh  
sed -i 's/make -j1 test/#make -j1 test/' ../clfs_*.sh 
sed -i 's/make tests/#make tests/' ../clfs_*.sh 
sed -i 's/make -j1 tests/#make -j1 tests/' ../clfs_*.sh 
sed -i 's/make -k test/#make -k test/' ../clfs_*.sh 

echo " "
echo "All checks and tests are disabled"
echo " "
