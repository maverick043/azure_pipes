# Kickstart Config for Automated Rocky Linux Installation
install
lang en_US.UTF-8
keyboard us
timezone America/New_York
rootpw --plaintext changeme

# Configure all four interfaces with DHCP
network --device=eth0 --bootproto=dhcp --activate
network --device=eth1 --bootproto=dhcp --activate
network --device=eth2 --bootproto=dhcp --activate
network --device=eth3 --bootproto=dhcp --activate

firewall --disabled
auth --useshadow --passalgo=sha512
selinux --disabled
bootloader --location=mbr
clearpart --all --initlabel
autopart --type=lvm
reboot
