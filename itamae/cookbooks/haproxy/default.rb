package 'haproxy'
include_cookbook 'prometheus-haproxy-exporter'

directory "/etc/haproxy" do
  owner 'root'
  group 'root'
  mode  '0755'
end

