include_cookbook 'haproxy'

template '/etc/haproxy/haproxy.cfg' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[haproxy]'
end

service 'haproxy' do
  action [:enable, :start]
end


