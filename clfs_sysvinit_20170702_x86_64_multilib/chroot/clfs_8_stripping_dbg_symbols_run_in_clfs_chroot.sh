#!/bin/bash

#Stripping debugging symbols...
/tools/bin/find /{,usr/}{bin,lib,lib64,sbin} -type f \
   -exec /tools/bin/strip --strip-debug '{}' ';'