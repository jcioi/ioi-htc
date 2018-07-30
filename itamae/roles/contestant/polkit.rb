remote_file "/etc/polkit-1/localauthority/90-mandatory.d/net.ioi18.contestant.pkla" do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[polkit]'
end

service 'polkit' do
  action :nothing
end
