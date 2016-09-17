
# Need 3Gig ram

#!/bin/bash -e

set -x # Trace execution

. /etc/profile
env-update

emerge --sync

gunzip -c /proc/config.gz > /usr/src/livecd.config
emerge genkernel grub
cp config-4.4.6-vbox /usr/src/linux/.config
cd /usr/src/linux

make oldconfig
cp .config /usr/src/kernel.config
genkernel --kernel-config=/usr/src/kernel.config all

grub-install /dev/sda

# Care about networking setup. Disable upredictable "predictable ifnames"
echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX rootfstype=ext4 net.ifnames=0"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Configure networking
ln -s net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default
echo 'config_eth0="dhcp"' >> /etc/conf.d/net

rc-update add sshd default

eselect profile set 6

exit 0 

#CFLAGS="-O2 -pipe -march=native"

echo <<EOF > /etc/portage/make.conf
CFLAGS="-O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"
USE="bindist"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
MAKEOPTS="-j5"
EOF

# Download my SSH keys. If you are not me, you want to change this
#mkdir -p /root/.ssh
#wget https://gist.github.com/andrey-utkin/2bb57efd85387edad34e/raw/b9d67d781f70699474154522eb84ff8bd528864d/authorized_keys -O /root/.ssh/authorized_keys

# eselect profile list
# [6] kde

# Install handy stuff
emerge -v \
  gentoolkit \
  sudo \
  syslog-ng \
  logrotate \
  \
  vim \
  #app-misc/screen \
  tmux \
  app-emulation/virtualbox-guest-additions
  www-client/chromium
# ratpoison
