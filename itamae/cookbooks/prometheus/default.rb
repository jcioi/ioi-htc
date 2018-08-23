node.reverse_merge!(
  prometheus: {
    version: 'v2.3.2',
    # mounts: [],
  },
)

include_cookbook 'docker'

user 'prometheus' do
  uid 900
  system_user true
end

directory '/etc/prometheus' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template "/etc/systemd/system/prometheus.service" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end
