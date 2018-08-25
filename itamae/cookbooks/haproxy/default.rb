package 'haproxy'
include_cookbook 'prometheus-haproxy-exporter'

directory "/etc/haproxy" do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/etc/systemd/system/haproxy.service.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/systemd/system/haproxy.service.d/override.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end
