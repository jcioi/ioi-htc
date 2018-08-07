node.reverse_merge!(
  cups: {
    log_level: 'debug',
    web_interface: true,
    listen: ['*:631'],
    server_alias: '*',
    external_auth: true,
  },
  nginx: {
    default_conf: false,
  },
  ioiprint: {
    config: {
      default_printer: 'PDF',
    },
  },
)

include_role 'base'
include_cookbook 'nginx'
include_cookbook 'codedeploy-agent'
include_cookbook 'cups'
include_cookbook 'cups-pdf'
include_cookbook 'canon-cups-drivers'
include_cookbook 'ioiprint'

template '/etc/nginx/conf.d/print.ioi18.net.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nginx try-reload]'
end

service  'nginx' do
  action [:enable, :start]
end
