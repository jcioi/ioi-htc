execute 'install atom' do
  script = <<EOF
tmp=$(mktemp --tmpdir "XXXXXXXXX.deb")
curl -fLsS -o "$tmp" https://github.com/atom/atom/releases/download/v1.29.0/atom-amd64.deb
echo "dfa598d38216ab9dc187e40d279cb69a57b6c9dc3d1ca8d0c4140bae90bd1838 $tmp" | sha256sum -c
apt-get install -y "$tmp"
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'dpkg -l atom'
end
