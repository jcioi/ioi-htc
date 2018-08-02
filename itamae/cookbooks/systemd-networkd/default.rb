if node[:hocho_ec2]
  template "/etc/systemd/network/default.network" do
    owner 'root'
    group 'root'
    mode  '0644'
  end

  file "/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg" do
    content "network: {config: disabled}\n"
    owner 'root'
    group 'root'
    mode  '0644'
  end
else
  execute "mkdir -p /etc/systemd/network && cp -pv -t /etc/systemd/network /run/systemd/network/*netplan*" do
    only_if "test -e /etc/netplan"
  end
end

execute "rm -rf /etc/netplan && netplan generate" do
  only_if "test -e /etc/netplan"
  notifies :restart, 'service[systemd-networkd]'
end

# package "netplan.io" do
#   action :remove
# end

service "systemd-networkd" do
  action [:enable, :start]
end

service "systemd-resolved" do
  action [:enable, :start]
end
