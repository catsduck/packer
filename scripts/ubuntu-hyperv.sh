#!/bin/bash -eux

# update apt
apt-get update

# install updates
apt-get upgrade -y

# clean apt
apt-get autoremove
apt-get clean

# create and setup ansible user
groupadd ansible
useradd -m -g ansible -s /bin/bash ansible
mkdir /home/ansible/.ssh
cat << EOF > /home/ansible/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+nwxFCRrhxk0eCZVyn7fdOm9/Ejjk8TDYTeUatG0nhX0zXEPl/oiUvZsRQdagJb43re59cYeNugegLpZZbbJIpO8P3EFw02MhxwOTHA+xrQHxW4alRUu/iVeaQtxU0lz+jlKKltD5dlq8SHBk3pR3vP0TL/96uPw0FXNv69rztnJNiM9f7bUhhLBKCPhzPVJL/rEIF09+tEzVT6BTRCnrY4Xtj8c3ch87ToCY5bh71TKxBdHDU3xFmG/Hqz2qFHVNZ2EIXkuw+EaNgWQG3a2dAW7C6lcxO9Wm1OKPAQ67+qaYWgn7S4kqYd1DGhzPIzkwoUh2H4V1GrVSi99cj8d0BryBmRTHS3OhUf/uYwASiiA6vaqiqGO3qK8WGtYvzk3ZnkGe1unpUnKBg5MSLomrBaDe94P589BVVi3vjGY7AS4cOF7RafyO+KetrkGMUwUTVqTlfjSYWEk7clfPp3XaeGgTy/Xd14GiEX86IMGkZ1AnVjZYm9eegY2PCd6agA8=
EOF
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
echo "ansible ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

# remote machine-id so it gets regenerated and avoids duplicates
>/etc/machine-id

# remove login and sudo access for the packer user
usermod --shell /usr/sbin/nologin packer
usermod -G packer packer
