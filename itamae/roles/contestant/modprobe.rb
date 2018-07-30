remote_file '/etc/modprobe.d/blacklist-ioi18.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[update-initramfs]'
end

execute 'update-initramfs' do
  action :nothing
  command 'update-initramfs -u'
end
