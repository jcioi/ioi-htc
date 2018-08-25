node.reverse_merge!(
  prometheus: {
    unbound_exporter: {
      blob: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/unbound_exporter-4f36729f553665a4268b5c265448977276a95096-20180825003823',
    },
  },
)

node[:prometheus][:exporter_proxy][:exporters][:unbound_exporter] = {path: '/unbound_exporter/metrics', url: 'http://localhost:9167/metrics'}

execute "install-unbound-exporter" do
  command "( " + \
    "destname=unbound_exporter.$(openssl dgst -sha1 /opt/unbound_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; " +
    "curl -Ssf -o $dest $(cat /opt/unbound_exporter.url) && " +
    "chmod +x $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/unbound_exporter && " +
    "if systemctl is-enabled prometheus-unbound-exporter.service; then systemctl restart prometheus-unbound-exporter.service; fi )"
  action :nothing
end

file "/opt/unbound_exporter.url" do
  content "#{node.dig(:prometheus, :unbound_exporter).fetch(:blob)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-unbound-exporter]', :immediately
end

execute 'systemctl daemon-reload && systemctl try-restart prometheus-unbound-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-unbound-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-unbound-exporter.service]', :immediately
end

service 'prometheus-unbound-exporter.service' do
  action [:enable, :start]
end
