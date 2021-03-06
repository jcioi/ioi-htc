node.reverse_merge!(
  nginx: {
    default_conf: false,
  },
)

include_role 'base'
include_cookbook 'cms'
include_cookbook 'nginx'
include_cookbook 'codedeploy-agent'

template '/etc/nginx/conf.d/admin.conf' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :run, 'execute[nginx try-reload]'
end

service 'cms-resourceservice.service' do
  action [:enable]
end

service 'cms-adminwebserver.service' do
  action [:enable]
end

service 'nginx.service' do
  action [:enable, :start]
end
