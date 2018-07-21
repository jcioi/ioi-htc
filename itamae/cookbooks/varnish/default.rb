node.reverse_merge!(
  varnish: {
    mem_size: "#{(node[:memory][:total].to_i * 0.8).to_i}k",
    listen: ':80',
    timeout_idle: 60, # keep-alive
  }
)
package 'varnish' do
  action :install
end

directory '/etc/systemd/system/varnish.service.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/systemd/system/varnish.service.d/exec.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end


