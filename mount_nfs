#! /bin/sh

#[ ! -d /Volumes/Data-ExFAT ] && sudo mkdir /Volumes/Data-ExFAT
[ ! -d /Volumes/DATA-FAT ] && sudo mkdir /Volumes/DATA-FAT && sudo chown wansongHome:admin /Volumes/DATA-FAT
#sudo mount -t nfs -o resvport 192.168.0.11:/mnt/mdisk3 /Volumes/Data-ExFAT
mount -t smbfs //wansong:14c3bd07@192.168.0.11/mdisk4 /Volumes/DATA-FAT
