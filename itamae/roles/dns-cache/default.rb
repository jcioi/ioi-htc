node.reverse_merge!(
  dns_cache: {
    threads: node[:cpu][:total].to_i,
    upstream: node.fetch(:resolvers),
    log_queries: true,
    stubs: [],
    outgoing_interfaces: %w(),
    interfaces: %w(0.0.0.0 ::0),
  },
)

include_role 'base'
include_cookbook 'systemd-networkd::disable-stub-resolver'

include_cookbook 'unbound'

1.upto(100) do |i|
  node[:dns_cache][:slab] = 2**i
  if node[:dns_cache][:slab] >= node[:dns_cache][:threads]
    break
  end
end

template '/etc/unbound/unbound.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  # notifies :reload, 'service[unbound]'
end

#directory '/mnt/vol/unbound-log' do
#  owner 'unbound'
#  group 'unbound'
#  mode  '0755'
#end
#link '/var/log/unbound' do
#  to '/mnt/vol/unbound-log'
#end

template "/etc/unbound/unbound.conf" do
  owner "root"
  group "root"
  mode  "0644"
end

directory "/var/log/unbound" do
  owner "unbound"
  group "unbound"
  mode  "0755"
end

#remote_file "/etc/unbound/named.cache" do
#  owner 'root'
#  group 'root'
#  mode  '0644'
#end

template '/etc/apparmor.d/local/usr.sbin.unbound' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl reload apparmor.service]', :immediately
end

remote_file '/etc/unbound/named.cache' do
  owner 'root'
  group 'root'
  mode  '0644'
end

execute 'systemctl reset-failed unbound' do
  only_if 'systemctl is-failed unbound'
end

service 'unbound' do
  action [:enable, :start]
end
