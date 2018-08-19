node.reverse_merge!(
  base: {
    timesyncd: false,
  },
)
include_role 'base'
include_cookbook 'chrony'

template '/etc/chrony/chrony.conf' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :restart, 'service[chrony]'
end

service 'chrony' do
  action [:enable, :start]
end

