node.reverse_merge!(
  cms: {
    tarball_url: 'https://github.com/cms-dev/cms/releases/download/v1.3.rc0/v1.3.rc0.tar.gz',
  },
)

# template '/usr/bin/ioi-install-cms' do
#   owner 'root'
#   group 'root'
#   mode '0755'
# end

# execute '/usr/bin/ioi-install-cms' do
#   not_if 'test -e /opt/cms'
# end

%w(
  /var/log/cms
  /var/cache/cms
  /var/lib/cms
).each do |_|
  directory _ do
    owner 'cmsuser'
    group 'cmsuser'
    mode  '0755'
  end
end

%w(
  cms.target
  cms-logservice.service
  cms-resourceservice.service
  cms-evaluationservice.service
  cms-scoringservice.service
  cms-contestwebserver.service
  cms-adminwebserver.service
  cms-worker.service
  cms-checker.service
  cms-proxyservice.service
).each do |_|
  remote_file "/etc/systemd/system/#{_}" do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :run, 'execute[systemctl daemon-reload]'
  end
end

service 'cms.target' do
  action [:enable]
end
