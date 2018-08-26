node.reverse_merge!(
  prometheus: {
    exporter_proxy: {
      blob: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/exporter_proxy-0.2.0',
      listen: "0.0.0.0:9099",
      exporters: {
        node_exporter: {path: '/node_exporter/metrics', url: 'http://localhost:9100/metrics'},
      },
    },
  },
)

execute "install-exporter-proxy" do
  command "( " + \
    "destname=exporter_proxy.$(openssl dgst -sha1 /opt/exporter_proxy.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; " +
    "curl -Ssf -o $dest $(cat /opt/exporter_proxy.url) && " +
    "chmod +x $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/exporter_proxy && " +
    "if systemctl is-enabled prometheus-exporter-proxy.service; then systemctl restart prometheus-exporter-proxy.service; fi )"
  action :nothing
end

file "/opt/exporter_proxy.url" do
  content "#{node.dig(:prometheus, :exporter_proxy).fetch(:blob)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-exporter-proxy]', :immediately
end

execute 'if systemctl is-enabled prometheus-exporter-proxy.service; then systemctl restart prometheus-exporter-proxy.service; fi' do
  action :nothing
end
template '/etc/exporter_proxy.yml' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[if systemctl is-enabled prometheus-exporter-proxy.service; then systemctl restart prometheus-exporter-proxy.service; fi]'
end

execute 'systemctl daemon-reload && systemctl try-restart prometheus-exporter-proxy.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-exporter-proxy.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-exporter-proxy.service]', :immediately
end

service 'prometheus-exporter-proxy.service' do
  action [:enable, :start]
end
