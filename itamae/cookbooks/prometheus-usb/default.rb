include_cookbook 'prometheus-node-exporter'

gem_package 'prometheus-client' do
  version '0.8.0'
end

remote_file '/usr/bin/prometheus-usb' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/systemd/system/prometheus-usb.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/systemd/system/prometheus-usb.timer' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'prometheus-usb.timer' do
  action [:enable, :start]
end
