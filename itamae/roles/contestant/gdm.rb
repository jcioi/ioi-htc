remote_file '/etc/gdm3/greeter.dconf-defaults' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[dpkg-reconfigure gdm3]'
end

execute 'dpkg-reconfigure gdm3' do
  action :nothing
end
