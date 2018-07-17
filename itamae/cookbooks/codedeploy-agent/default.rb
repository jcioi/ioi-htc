node.reverse_merge!(
  codedeploy_agent: {
    commit: '81ffec26b1a394e5c951bc2e8a8ba3e731e81148',
  }
)

include_cookbook 'deploy-user'

template '/usr/bin/ioi-install-codedeploy-agent' do
  owner 'root'
  group 'root'
  mode  '0755'
end

execute 'ioi-install-codedeploy-agent' do
  not_if 'ioi-install-codedeploy-agent --is-latest'
end

remote_file "/usr/bin/codedeploy-agent" do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file "/etc/systemd/system/codedeploy-agent.service" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

directory '/etc/codedeploy-agent' do
  owner 'root'
  group 'root'
  mode  '0755'
end
directory '/etc/codedeploy-agent/conf' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/codedeploy-agent/conf/codedeployagent.yml' do
  owner 'root'
  group 'root'
  mode  '0644'
end


service 'codedeploy-agent.service' do
  action [:enable, :start]
end
