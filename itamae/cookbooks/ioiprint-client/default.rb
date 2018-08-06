include_cookbook 'cups'

remote_file '/usr/lib/cups/backend/ioiprint' do
  owner 'root'
  group 'root'
  mode '0755'
end

link '/usr/lib/cups/backend/ioiprints' do
  to 'ioiprint'
end
