node.reverse_merge!(
  cms: {
    isolate: {
      tarball_url: 'https://github.com/ioi/isolate/archive/c679ae936d8e8d64e5dab553bdf1b22261324315.tar.gz',
    },
  },
)

include_cookbook 'isolate-recommendation'

execute 'rm -f /opt/cms-isolate.mark' do
  action :nothing
end

file '/opt/cms-isolate.url' do
  content "#{node[:cms][:isolate].fetch(:tarball_url)}\n"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[rm -f /opt/cms-isolate.mark]', :immediately
end

template '/usr/bin/ioi-install-isolate' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/opt/cms-isolate' do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/var/lib/isolate' do
  owner 'root'
  group 'root'
  mode  '0700'
end

template '/etc/isolate' do
  owner 'root'
  group 'root'
  mode  '0644'
end

execute '/usr/bin/ioi-install-isolate' do
  not_if 'test -e "/usr/bin/isolate" -a -e /opt/cms-isolate.mark'
end
