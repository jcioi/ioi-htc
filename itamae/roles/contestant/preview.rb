username = 'contestant'
password = '$6$ANZj7Ypm8p6tqnsm$P9YiyO3TXzld6fnC6DNgXURZJB2gsGfYghjypzhWM83zwtuVDPgAiOTLvc.SJqp3tD8e62N46x9s1vdpa.4jQ/'  # "ioi" in plain text

user username do
  uid 1000
  gid 1000
  home "/home/#{username}"
  shell '/bin/bash'
  password password
  create_home false
end

user 'root' do
  password password
end

# Networks are managed by NetworkManager so that VM users can change settings using gnome-control-center
# NB. NetworkManager requires a user to belong to "netdev" group to change network settings

execute "usermod -a -G netdev #{username.shellescape}" do
  only_if "! getent group netdev | cut -d: -f4 | tr , '\\n' | grep -Fxq #{username.shellescape}"
end

package 'netplan.io'

directory '/etc/netplan' do
  owner 'root'
  group 'root'
  mode '755'
end

file '/etc/netplan/01-netcfg.yaml' do
  owner 'root'
  group 'root'
  mode '644'
  content <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF
end

file '/etc/systemd/network/default.network' do
  action :delete
end
