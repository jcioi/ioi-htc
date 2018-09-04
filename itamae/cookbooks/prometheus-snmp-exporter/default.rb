node.reverse_merge!(
  prometheus: {
    snmp_exporter: {
      tarball: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/snmp_exporter-0.12.0.tar.gz',
    },
  },
)

execute "install-snmp-exporter" do
  command "( " + \
    "destname=snmp_exporter.$(openssl dgst -sha1 /opt/snmp_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; mkdir -p $dest && " +
    "curl -Ssf $(cat /opt/snmp_exporter.url) | tar xzf - --strip-components=1 -C $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/snmp_exporter && " +
    "if systemctl is-enabled prometheus-snmp-exporter.service; then systemctl restart prometheus-snmp-exporter.service; fi )"
  action :nothing
end

file "/opt/snmp_exporter.url" do
  content "#{node.dig(:prometheus, :snmp_exporter).fetch(:tarball)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-snmp-exporter]', :immediately
end


execute 'systemctl daemon-reload && systemctl try-restart prometheus-snmp-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-snmp-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-snmp-exporter.service]', :immediately
end

remote_file '/etc/prometheus/snmp.yml' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-snmp-exporter.service]', :immediately
end


service 'prometheus-snmp-exporter.service' do
  action [:enable, :start]
end
