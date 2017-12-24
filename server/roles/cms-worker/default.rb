include_cookbook 'cms'
include_cookbook 'cms::isolate'

service 'cms-resourceservice.service' do
  action [:enable, :start]
end

service 'cms-worker.service' do
  action [:enable, :start]
end
