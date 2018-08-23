node.reverse_merge!(
  prometheus: {
    mounts: %w(
      /mnt/vol/prometheus-data:/prometheus-data:rw
    ),
  },
)

include_recipe './config.rb'

include_role 'base'
include_cookbook 'mnt-vol'
include_cookbook 'prometheus'
include_recipe './cloudwatch.rb'

directory '/mnt/vol/prometheus-data' do
  owner 'prometheus'
  group 'prometheus'
  mode  '0755'
end

file '/etc/prometheus/prometheus.yml' do
  content "#{node[:prometheus][:config].to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[prometheus.service]'
end

service 'prometheus.service' do
  action [:enable, :start]
end
