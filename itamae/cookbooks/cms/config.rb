node.reverse_merge!(
  cms: {
    config_url: "https://s3-apne1.ioi18.net/ioi18-infra/cms/#{node[:cms].fetch(:cluster)}/config.json",
  },
)

file '/etc/cms_config_url.txt' do
  content "#{node[:cms][:config_url]}\n"
  owner 'root'
  group 'root'
  mode  '0640'
end

remote_file '/usr/bin/ioi-update-cms-config' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/systemd/system/ioi-update-cms-config.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/systemd/system/ioi-update-cms-config.timer' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

file '/etc/cms.conf' do
  owner 'root'
  group 'cmsuser'
  mode  '0640'
end

service 'ioi-update-cms-config.timer' do
  action [:enable, :start]
end

execute 'ioi-update-cms-config' do
  not_if 'grep -q "{" /etc/cms.conf'
end
