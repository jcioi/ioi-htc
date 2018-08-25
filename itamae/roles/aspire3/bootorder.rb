# UEFI BootOrder is ignored under some unknown conditions!
# Set BootNext on every boot instead.

remote_file '/usr/sbin/ioi-set-bootorder' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/systemd/system/ioi-set-bootorder.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'ioi-set-bootorder' do
  action [:enable, :start]
end
