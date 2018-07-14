node.reverse_merge!(
  cms: {
    isolate: {
      tarball_url: 'https://github.com/ioi/isolate/archive/60caa494d3106fbf19f741a2454c5f030466b351.tar.gz',
    },
  },
)

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

execute '/usr/bin/ioi-install-isolate' do
  not_if 'test -e /usr/bin/isolate'
end
