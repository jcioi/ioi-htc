directory '/etc/systemd/logind.conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/systemd/logind.conf.d/disable-power-switches.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end
