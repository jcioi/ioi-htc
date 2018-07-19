package 'dbus-user-session'

remote_file '/etc/systemd/user/ioi-trust-launchers.service' do
  owner 'root'
  group 'root'
  mode '644'
end

directory '/etc/systemd/user/default.target.wants' do
  owner 'root'
  group 'root'
  mode '755'
end

link '/etc/systemd/user/default.target.wants/ioi-trust-launchers.service' do
  to '/etc/systemd/user/ioi-trust-launchers.service'
end
