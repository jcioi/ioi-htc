include_role 'base'
include_cookbook 'cms'
include_cookbook 'codedeploy-agent'

service 'cms-proxyservice.service' do
  action [:enable]
end
