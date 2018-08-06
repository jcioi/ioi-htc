node.reverse_merge!(
  in_container: run_command("systemd-detect-virt --container", error: false).exit_status == 0,
  base: {
    zabbix_agent: false, # TODO: zabbix_agent
  },
)

if node[:desired_hostname] && node[:desired_hostname] != node[:hostname]
  execute "set hostname" do
    command "hostnamectl set-hostname #{node[:desired_hostname]}"
  end
  node[:hostname] = node[:desired_hostname]
end

include_cookbook 'apt-source-ubuntu'

directory "/usr/share/cnw" do
  owner 'root'
  group 'root'
  mode  '0755'
end

include_cookbook 'op-user'
include_cookbook 'sshd'

include_cookbook 'systemd-networkd'

template "/etc/systemd/timesyncd.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[systemd-timesyncd]' unless node[:in_container]
end

unless node[:in_container]
  service "systemd-timesyncd" do
    action [:enable, :start]
  end
end

%w(
  sudo
  dnsutils
  dstat
  vim
  mtr
  tcpdump
  netcat
  htop
  jq
  curl
  apt-transport-https
  git
  ruby
  ruby-bundler
  btrfs-tools
).each do |_|
  package _
end


include_cookbook 'iperf3'

if node.dig(:base, :zabbix_agent)
  include_cookbook 'zabbix-agent'
end

unless node[:hocho_ec2]
  include_cookbook 'swap'
end

file '/root/.ssh/authorized_keys' do
  action :delete
end

file '/home/ubuntu/.ssh/authorized_keys' do
  action :delete
end
