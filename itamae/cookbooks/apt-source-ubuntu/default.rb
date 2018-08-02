template '/etc/apt/sources.list' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[apt-get update]'
end
