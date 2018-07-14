node.reverse_merge!(
  ssh: {
    port: [9922, 22],
  },
)

package "openssh-server" do
end

template "/etc/ssh/sshd_config" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[sshd]'
end

service "sshd" do
  action [:enable, :start]
end
