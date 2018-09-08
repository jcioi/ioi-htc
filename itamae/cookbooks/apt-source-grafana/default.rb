include_cookbook 'apt-key-packagecloud'
template "/etc/apt/sources.list.d/grafana.list" do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, "execute[apt-get update]"
end
