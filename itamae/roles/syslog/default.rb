node.reverse_merge!(
  syslog: {
    root: '/mnt/vol/log',
  },
)


include_role 'base'
include_cookbook 'mnt-vol'
include_cookbook 'fluentd'
include_cookbook 'nftables'

template '/etc/nftables.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

directory node[:syslog].fetch(:root) do
  owner 'fluentd'
  group 'root'
  mode  '0755'
end

directory "#{node[:syslog].fetch(:root)}/buffer" do
  owner 'fluentd'
  group 'root'
  mode  '0755'
end

gem_package "fluent-plugin-rewrite-tag-filter"
gem_package "fluent-plugin-nfct-parser"
gem_package "fluent-plugin-s3"

template '/etc/fluent/fluent.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

service 'fluentd' do
  action [:enable, :start]
end


