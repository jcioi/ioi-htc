include_role 'base'
include_cookbook 'cms'
include_cookbook 'cms::isolate'

service 'cms-resourceservice.service' do
  action [:enable]
end

service 'cms-worker.service' do
  action [:enable]
end
