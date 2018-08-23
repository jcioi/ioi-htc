node.reverse_merge!(
  prometheus: {
    node_exporter: {
      tarball: 'https://s3-apne1.ioi18.net/ioi18-infra/packages/node_exporter-0.16.0.tar.gz',
      collectors: %w(
        conntrack
        diskstats
        entropy
        filefd
        filesystem
        loadavg
        mdadm
        meminfo
        netdev
        netstat
        sockstat
        stat
        textfile
        time
        uname
        vmstat
        logind
        systemd
      )
    },
  },
)

execute "install-node-exporter" do
  command "( " + \
    "destname=node_exporter.$(openssl dgst -sha1 /opt/node_exporter.url|cut -f2 -d' '); dest=/opt/$destname; " +
    "rm -rf $dest; mkdir -p $dest && " +
    "curl -Ssf $(cat /opt/node_exporter.url) | tar xzf - --strip-components=1 -C $dest && " +
    "ln -s $destname ${dest}.link && " +
    "mv -Tfv ${dest}.link /opt/node_exporter && " +
    "if systemctl is-enabled prometheus-node-exporter.service; then systemctl restart prometheus-node-exporter.service; fi )"
  action :nothing
end

file "/opt/node_exporter.url" do
  content "#{node.dig(:prometheus, :node_exporter).fetch(:tarball)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[install-node-exporter]', :immediately
end


directory '/var/lib/prometheus-node-exporter' do
  owner 'root'
  group 'root'
  mode  '0755'
end
directory '/var/lib/prometheus-node-exporter/textfile_collector' do
  owner 'root'
  group 'root'
  mode  '0755'
end

execute 'systemctl daemon-reload && systemctl try-restart prometheus-node-exporter.service' do
  action :nothing
end
template '/etc/systemd/system/prometheus-node-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload && systemctl try-restart prometheus-node-exporter.service]', :immediately
end

service 'prometheus-node-exporter.service' do
  action [:enable, :start]
end
