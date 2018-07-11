rm -rf /tmp/itamae

apt-get autoremove --purge
apt-get clean

sed -e '/http::proxy/Id' -i /etc/apt/apt.conf

usermod -L provisioner
