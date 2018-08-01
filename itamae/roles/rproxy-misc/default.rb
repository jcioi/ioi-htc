include_role 'base'
include_cookbook 'nginx'
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

%w(
  /etc/nginx/conf.d/auth.ioi18.net.conf
).each do |_|
  template _ do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :run, 'execute[nginx try-reload]'
  end
end

service  'nginx' do
  action [:enable, :start]
end
