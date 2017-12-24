include_cookbook 'cms'

service 'cms-resourceservice.service' do
  action [:enable, :start]
end

service 'cms-checker.service' do
  action [:enable, :start]
end
