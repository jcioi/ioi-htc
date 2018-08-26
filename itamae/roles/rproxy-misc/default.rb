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
  /etc/nginx/utils/omniauth_enable_location.conf
  /etc/nginx/utils/omniauth_enable_server.conf

  /etc/nginx/conf.d/auth.ioi18.net.conf
  /etc/nginx/conf.d/admin-dev.ioi18.net.conf
  /etc/nginx/conf.d/contest-dev.ioi18.net.conf

  /etc/nginx/conf.d/translation.ioi18.net.conf
  /etc/nginx/conf.d/print.ioi18.net.conf
  /etc/nginx/conf.d/boot.ioi18.net.conf

  /etc/nginx/conf.d/console.ioi18.net.conf

  /etc/nginx/conf.d/netbox.ioi18.net.conf

  /etc/nginx/conf.d/prometheus.conf
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
