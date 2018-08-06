package 'printer-driver-cups-pdf' do
  action :install
end

remote_file '/etc/cups/cups-pdf.conf' do
  owner 'root'
  group 'root'
  mode '644'
end