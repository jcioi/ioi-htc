node.reverse_merge!(
  prometheus: {
    haproxy_exporter: {
      tarball: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/haproxy_exporter-0.16.0.tar.gz',
    },
  },
)

node[:prometheus][:exporter_proxy][:exporters][:haproxy_exporter] = {path: '/haproxy_exporter/metrics', url: 'http://localhost:9101/metrics'}

execute "install-haproxy-exporter" do
  command "( " + \
    "destname=haproxy_exporter.$(openssl dgst -sha1 /opt/haproxy_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; mkdir -p $dest && " +
    "curl -Ssf $(cat /opt/haproxy_exporter.url) | tar xzf - --strip-components=1 -C $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/haproxy_exporter && " +
    "if systemctl is-enabled prometheus-haproxy-exporter.service; then systemctl restart prometheus-haproxy-exporter.service; fi )"
  action :nothing
end

file "/opt/haproxy_exporter.url" do
  content "#{node.dig(:prometheus, :haproxy_exporter).fetch(:tarball)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-haproxy-exporter]', :immediately
end


execute 'systemctl daemon-reload && systemctl try-restart prometheus-haproxy-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-haproxy-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-haproxy-exporter.service]', :immediately
end

service 'prometheus-haproxy-exporter.service' do
  action [:enable, :start]
end
