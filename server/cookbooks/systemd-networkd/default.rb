if node[:hocho_ec2]
  template "/etc/systemd/network/default.network" do
    owner 'root'
    group 'root'
    mode  '0644'
  end
end

execute "rm -fv /run/systemd/network/*netplan*" do
  only_if "test -e /lib/systemd/system-generators/netplan"
end

package "netplan.io" do
  action :remove
end

service "systemd-networkd" do
  action [:enable, :start]
end


