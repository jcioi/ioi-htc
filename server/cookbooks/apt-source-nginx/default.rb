apt_key 'C300EE8C'

template "/etc/apt/sources.list.d/nginx.list" do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, "execute[apt-get update]"
end
