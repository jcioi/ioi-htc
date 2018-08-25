node.reverse_merge!(
  ioi_set_hostname: {
  }
)

file '/etc/hostname.template' do
  content node[:ioi_set_hostname].fetch(:template)
  owner 'root'
  group 'root'
  mode '0644'
end

remote_file '/usr/sbin/ioi-set-hostname' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/systemd/system/ioi-set-hostname.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'ioi-set-hostname.service' do
  action :enable
end
