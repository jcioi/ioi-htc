include_cookbook 'cms'

service 'cms-resourceservice.service' do
  action [:enable, :start]
end

service 'cms-evaluationservice.service' do
  action [:enable, :start]
end
