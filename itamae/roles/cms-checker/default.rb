include_role 'base'
include_cookbook 'cms'
include_cookbook 'codedeploy-agent'

service 'cms-resourceservice.service' do
  action [:enable]
end

service 'cms-checker.service' do
  action [:enable]
end
