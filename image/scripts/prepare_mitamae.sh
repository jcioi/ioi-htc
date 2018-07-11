if [ ! -e /etc/apt/sources.list.d/nekomit.list ]; then
    apt-get update
    apt-get install -y curl gnupg
    curl -Ssf https://sorah.jp/packaging/debian/C3FF3305.pub.txt | apt-key add -
    echo 'deb http://deb.nekom.it/ bionic main' > /etc/apt/sources.list.d/nekomit.list
fi
apt-get update
apt-get install -y mitamae
