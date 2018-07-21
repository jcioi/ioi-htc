node.reverse_merge!({
  fproxy: {
    allowed_cidrs: {
      site: node[:site_cidr],
    },
    ssl_ports: [443]
  }
})

include_role 'base'
include_cookbook 'squid'

template "/etc/squid/squid.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[squid]'
end

service "squid" do
  action [:enable, :start]
end
