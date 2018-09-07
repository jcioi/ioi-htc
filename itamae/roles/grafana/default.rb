include_role 'base'
include_cookbook 'grafana'

template '/etc/grafana/grafana.ini' do
  owner 'root'
  group 'root'
  mode  '0644'
end
