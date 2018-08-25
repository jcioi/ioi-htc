node.reverse_merge!(
  prometheus: {
    varnish_exporter: {
      tarball: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/varnish_exporter-1.4.1.tar.gz',
    },
  },
)

node[:prometheus][:exporter_proxy][:exporters][:varnish_exporter] = {path: '/varnish_exporter/metrics', url: 'http://localhost:9131/metrics'}

execute "install-varnish-exporter" do
  command "( " + \
    "destname=varnish_exporter.$(openssl dgst -sha1 /opt/varnish_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; mkdir -p $dest && " +
    "curl -Ssf $(cat /opt/varnish_exporter.url) | tar xzf - --strip-components=1 -C $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/varnish_exporter && " +
    "if systemctl is-enabled prometheus-varnish-exporter.service; then systemctl restart prometheus-varnish-exporter.service; fi )"
  action :nothing
end

file "/opt/varnish_exporter.url" do
  content "#{node.dig(:prometheus, :varnish_exporter).fetch(:tarball)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-varnish-exporter]', :immediately
end


execute 'systemctl daemon-reload && systemctl try-restart prometheus-varnish-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-varnish-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-varnish-exporter.service]', :immediately
end

service 'prometheus-varnish-exporter.service' do
  action [:enable, :start]
end
