#!/bin/bash -e

### Boot with Rescue System

### Download this script and execute
### wget https://github.com/decent-im/gebootstrap/raw/master/0-bootstrap-gentoo.sh
### chmod a+x 0-bootstrap-gentoo.sh
### ./0-bootstrap-gentoo.sh

# Partitions
# sda1 = boot, ext2
# sda2 = swap
# sda3 = root, ext4

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
# From http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +200M # 200 MB boot partition
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +2G # 2 GB swap partition
  t # change partition type
  2 # partition 2
  82 # Swap type
  n # new partition
  p # primary
  3 # partition number 3
    # default, start immediately
    # default, to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

mkswap /dev/sda2
swapon /dev/sda2

mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda3

mkdir /mnt/a
mount /dev/sda3 /mnt/a
mkdir /mnt/a/boot
mount /dev/sda1 /mnt/a/boot

cd /mnt/a
mkdir etc

# set up filesystem mount

cat <<EOF > etc/fstab
/dev/sda1 /boot ext2 noauto,noatime 1 2
/dev/sda3 /     ext4 noatime        0 1
/dev/sda2 none swap defaults
EOF

# Download stage3
DISTFILES_DIR='http://distfiles.gentoo.org/releases/amd64/autobuilds'
#STAGE_PATH=`wget $DISTFILES_DIR/latest-stage3-amd64-hardened+nomultilib.txt -O - -q | tail -1 | sed 's/ .*//'`
STAGE_PATH=`wget $DISTFILES_DIR/latest-stage3-amd64.txt -O - -q | tail -1 | sed 's/ .*//'`
wget $DISTFILES_DIR/$STAGE_PATH
tar xaf stage*.tar.*

wget http://distfiles.gentoo.org/releases/snapshots/current/portage-latest.tar.xz
tar xaf portage-latest.tar.xz -C usr

for x in dev sys proc
do
  mount --rbind {/,}$x
done

cp -L {/,}etc/resolv.conf

#wget https://github.com/decent-im/gebootstrap/raw/master/1-bootstrap-gentoo-chroot.sh
#chmod a+x 1-bootstrap-gentoo-chroot.sh
#chroot . ./1-bootstrap-gentoo-chroot.sh
