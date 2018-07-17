include_role 'base'
include_cookbook 'cms'

service 'cms-resourceservice.service' do
  action [:enable]
end

service 'cms-scoringservice.service' do
  action [:enable]
end
