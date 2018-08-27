include_cookbook 'prometheus-node-exporter'

package 'libffi-dev'
package 'ruby-dev'
package 'libcups2'

gem_package 'prometheus-client' do
  version '0.8.0'
end
gem_package 'cupsffi' do
  version '0.1.7'
end

remote_file '/usr/bin/prometheus-cups' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/systemd/system/prometheus-cups.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/systemd/system/prometheus-cups.timer' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'prometheus-cups.timer' do
  action [:enable, :start]
end
