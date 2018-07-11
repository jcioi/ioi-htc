rm -rf /tmp/itamae

apt-get autoremove --purge
apt-get clean
find /var/lib/apt/lists -type f -delete

sed -e '/http::proxy/Id' -i /etc/apt/apt.conf

usermod -L provisioner
