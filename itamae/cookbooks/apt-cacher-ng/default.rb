package 'apt-cacher-ng'

remote_file '/etc/apt-cacher-ng/acng.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[apt-cacher-ng]'
end

service 'apt-cacher-ng' do
  action [:enable, :start]
end
