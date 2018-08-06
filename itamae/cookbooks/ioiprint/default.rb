node.reverse_merge!(
  ioiprint: {
    concurrency: 2,
    timezone: 'Asia/Tokyo',
    config: {
      contestant_max_pages: 10,
      cups_server: 'localhost:631',
    },
  },
)

%w[
  python3
  python3-pip
  python3-venv
  cups-bsd
  qpdf
  tzdata
  wkhtmltopdf
  xvfb
].each do |_|
  package _ do
    action :install
  end
end

user 'ioiprint' do
  uid 900
  shell '/bin/false'
  system_user true
end

remote_file '/etc/sudoers.d/ioiprint-deploy' do
  owner 'root'
  group 'root'
  mode  '0640'
end

%w(
  /opt/ioiprint_venv
  /opt/ioiprint
).each do |_|
  directory _ do
    owner 'deploy'
    group 'deploy'
    mode  '0755'
  end
end

file '/etc/ioiprint.env' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<EOF
TZ=#{node.dig(:ioiprint, :timezone)}
WEB_CONCURRENCY=#{node.dig(:ioiprint, :concurrency)}
EOF
end

file '/etc/ioiprint.json' do
  owner 'root'
  group 'root'
  mode '0644'
  content JSON.dump(node.dig(:ioiprint, :config))
end

remote_file '/etc/systemd/system/ioiprint.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'ioiprint' do
  action :enable
end
