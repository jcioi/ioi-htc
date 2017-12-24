include_cookbook 'cms'
include_cookbook 'nginx'

template '/etc/nginx/conf.d/default.conf' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :run, 'execute[nginx try-reload]'
end

service 'cms-resourceservice.service' do
  action [:enable, :start]
end

service 'cms-adminwebserver.service' do
  action [:enable, :start]
end

service 'nginx.service' do
  action [:enable, :start]
end
