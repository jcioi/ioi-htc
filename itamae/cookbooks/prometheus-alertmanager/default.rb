node.reverse_merge!(
  prometheus: {
    alertmanager: {
      version: 'v0.15.2',
      mounts: [],
    },
  },
)

include_cookbook 'docker'

template "/etc/systemd/system/prometheus-alertmanager.service" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
