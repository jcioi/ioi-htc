%w[
  ioi-force-logout
].each do |cmd|
  remote_file "/usr/bin/#{cmd}" do
    owner 'root'
    group 'ioi'
    mode '750'
  end
end
