node.reverse_merge!(
  cups: {
    log_level: 'warn',
    web_interface: false,
    listen: [
      'localhost:631',
    ],
  },
)

package 'cups' do
  action :install
end

template '/etc/cups/cupsd.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[cups]'
end

service 'cups' do
  action :enable
end

service 'cups-browsed' do
  action [:disable, :stop]
end

include_cookbook 'prometheus-cups'
