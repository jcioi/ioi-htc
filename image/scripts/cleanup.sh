systemd-tmpfiles --remove

apt-get autoremove --purge
apt-get clean
find /var/lib/apt/lists -type f -delete

sed -e '/http::proxy/Id' -i /etc/apt/apt.conf

usermod -L provisioner

for idfile in /etc/machine-id /var/lib/dbus/machine-id; do
    test -f "$idfile" && truncate -s 0 "$idfile"
done
