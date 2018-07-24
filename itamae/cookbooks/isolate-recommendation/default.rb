execute 'systemd-tmpfiles --create /etc/tmpfiles.d/isolate-recommendation.conf' do
  action :nothing
end
template '/etc/tmpfiles.d/isolate-recommendation.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemd-tmpfiles --create /etc/tmpfiles.d/isolate-recommendation.conf]'
end

