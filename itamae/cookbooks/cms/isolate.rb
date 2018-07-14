template '/usr/bin/ioi-install-isolate' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute '/usr/bin/ioi-install-isolate' do
  not_if 'test -e /usr/bin/isolate'
end


