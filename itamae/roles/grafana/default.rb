include_role 'base'
include_cookbook 'grafana'
include_cookbook 'nginx'

template '/etc/grafana/grafana.ini' do
  owner 'root'
  group 'root'
  mode  '0644'
end

service 'grafana-server.service' do
  action [:enable, :start]
end

template '/etc/nginx/conf.d/grafana.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nginx try-reload]'
end
