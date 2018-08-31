node.reverse_merge!(
  cups: {
    log_level: 'debug',
    web_interface: true,
    listen: ['localhost:631'],
#    server_alias: '*',
    external_auth: true,
  },
  cups_pdf: {
    out: '/var/spool/cups-pdf/output',
    user_umask: '0022',
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

if node.dig(:hocho_ec2, :tags, :IoiprintEnv) == 'prd'
  node.merge!(
    ioiprint: {
      config: {
        translation_printer: 'conf',
        default_printer: 'ref',
      },
    },
  )
end

include_role 'base'
include_cookbook 'nginx'
include_cookbook 'codedeploy-agent'
include_cookbook 'cups'
include_cookbook 'cups-pdf'
include_cookbook 'canon-cups-drivers'
include_cookbook 'ioiprint'

directory '/var/spool/cups-pdf/output' do
  owner 'ioiprint'
  group 'ioiprint'
  mode '755'
end

template '/etc/nginx/conf.d/print.ioi18.net.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nginx try-reload]'
end

service  'nginx' do
  action [:enable, :start]
end
