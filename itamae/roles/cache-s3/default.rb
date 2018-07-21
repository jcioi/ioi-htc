include_role 'base'
include_cookbook 'varnish'
include_cookbook 'haproxy'

cn = "cache.s3-apne1.ioi18.net"
file '/etc/haproxy/https.crt' do
  content "#{[
    node[:secrets].fetch(:"acme_cert_#{cn}"),
    node[:secrets].fetch(:"acme_key_#{cn}"),
    node[:secrets].fetch(:"acme_chain_#{cn}"),
  ].join(?\n)}\n"
  owner 'root'
  group 'root'
  mode  '0600'
end

template '/etc/haproxy/haproxy.cfg' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[haproxy]'
end

service 'haproxy' do
  action [:enable, :start]
end

template '/etc/varnish/varnish.vcl' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[varnish]'
end

service 'varnish' do
  action [:enable, :start]
end
