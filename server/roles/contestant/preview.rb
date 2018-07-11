username = 'contestant'
password = '$6$ANZj7Ypm8p6tqnsm$P9YiyO3TXzld6fnC6DNgXURZJB2gsGfYghjypzhWM83zwtuVDPgAiOTLvc.SJqp3tD8e62N46x9s1vdpa.4jQ/'  # "ioi" in plain text

group username do
  gid 1000
end

user username do
  uid 1000
  gid 1000
  home "/home/#{username}"
  shell '/bin/bash'
  password password
  create_home true
end

file '/etc/sudoers.d/contestant' do
  owner 'root'
  group 'root'
  mode '640'
  content "#{username} ALL= ALL"
end
