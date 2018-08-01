template '/etc/systemd/resolved.conf.d/local.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[systemd-resolved]'
end

directory '/run/systemd/resolve' do
  owner 'systemd-resolve'
  group 'systemd-resolve'
  mode '755'
end

execute 'cp /etc/resolv.conf /run/systemd/resolve/resolv.conf' do
  user 'systemd-resolve'
  not_if 'test -e /run/systemd/resolve/resolv.conf'
end

link '/etc/resolv.conf' do
  to '/run/systemd/resolve/resolv.conf'
  force true
end


