execute 'download fog installer' do
  script = <<EOF
tmp=$(mktemp --tmpdir "XXXXXXXXX.tar.gz")
mkdir -p /opt/fogproject
curl -fLsS -o "$tmp" https://github.com/FOGProject/fogproject/archive/1.5.4.tar.gz
echo "e8e1ad8ddc8e2926b1cf407f21cec1dc57c30a65e9411ab8df7d10a454683015 $tmp" | sha256sum -c
tar zxf "$tmp" -C /opt/fogproject --strip=1
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/fogproject/bin/installfog.sh'
  notifies :run, 'execute[installfog.sh]'
end

directory '/opt/fog' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/opt/fog/.fogsettings' do
  owner 'root'
  group 'root'
  mode '0600'
  notifies :run, 'execute[installfog.sh]'
end

execute 'installfog.sh' do
  command 'cd /opt/fogproject/bin && ./installfog.sh --autoaccept'
  action :nothing
end
