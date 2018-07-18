execute 'install eclipse' do
  script = <<EOF
mkdir -p /opt/eclipse
curl -fLsS http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-java-photon-R-linux-gtk-x86_64.tar.gz \
  | tar zx -C /opt/eclipse --strip=1
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/eclipse/eclipse'
end

link '/usr/local/bin/eclipse' do
  to '/opt/eclipse/eclipse'
end
