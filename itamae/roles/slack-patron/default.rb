include_cookbook 'slack-patron'
include_cookbook 'nginx'

template '/etc/nginx/conf.d/slack-patron.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nginx try-reload]'
end
