%w[
  ioi-force-logout
  ioi-purge-userdata
].each do |cmd|
  remote_file "/usr/bin/#{cmd}" do
    owner 'root'
    group 'ioi'
    mode '750'
  end
end
