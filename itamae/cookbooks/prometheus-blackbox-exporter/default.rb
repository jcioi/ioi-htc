node.reverse_merge!(
  prometheus: {
    blackbox_exporter: {
      tarball: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/blackbox_exporter-0.12.0.tar.gz',
      config: {
      },
    },
  },
)

execute "install-blackbox-exporter" do
  command "( " + \
    "destname=blackbox_exporter.$(openssl dgst -sha1 /opt/blackbox_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; mkdir -p $dest && " +
    "curl -Ssf $(cat /opt/blackbox_exporter.url) | tar xzf - --strip-components=1 -C $dest && " +
    "setcap cap_net_raw+ep ${dest}/blackbox_exporter && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/blackbox_exporter && " +
    "if systemctl is-enabled prometheus-blackbox-exporter.service; then systemctl restart prometheus-blackbox-exporter.service; fi )"
  action :nothing
end

file "/opt/blackbox_exporter.url" do
  content "#{node.dig(:prometheus, :blackbox_exporter).fetch(:tarball)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-blackbox-exporter]', :immediately
end

file "/etc/prometheus/blackbox.yml" do
  content "#{node[:prometheus][:blackbox_exporter].fetch(:config).to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, "service[prometheus-blackbox-exporter.service]"
end

execute 'systemctl daemon-reload && systemctl try-restart prometheus-blackbox-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-blackbox-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-blackbox-exporter.service]', :immediately
end

service 'prometheus-blackbox-exporter.service' do
  action [:enable, :start]
end
