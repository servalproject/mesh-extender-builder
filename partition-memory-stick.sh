#!/bin/bash
if [[ "$1" == "" ]]; then
  echo "usage: partition-memory-stick <device>"
  echo "       eg partition-memory-stick sdb"
  echo "WARNING: This script proceeds without asking any questions."
  echo "         If you use it on the wrong disk you will trash the partition table"
  echo "         and probably lose all your data."
  exit
fi
device=$1

# Do check if the disk is mounted anywhere
mounts=`mount | grep /dev/$device | wc -l`
if [[ $mounts != 0 ]]; then
  echo "That disk is mounted.  Try another."
  exit
fi

if [ ! -e /dev/$device ]; then
  echo "/dev/$device doesn't exist."
  exit
fi

fdisk /dev/$device <<EOF
d
1
d
2
d
3
d
4
n
p
1

+1G
n
p
2

+1G
n
p
3


t
1
b
w
EOF
echo
echo
echo
echo "Finished fdisk: remove and re-insert memory stick and run populate-memory-stick"
