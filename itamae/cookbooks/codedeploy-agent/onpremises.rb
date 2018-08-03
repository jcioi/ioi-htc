node.reverse_merge!(
  codedeploy_agent: {
    onpremises: {
      region: 'ap-northeast-1',
      role_arn: 'arn:aws:iam::550372229658:role/IoiCodeDeployOnpremiseRole',
      tags: {},
      iam_user: {
        access_key_id: node[:secrets].fetch(:codedeploy_onpremise_iam_user_access_key),
        secret_key: node[:secrets].fetch(:codedeploy_onpremise_iam_user_secret_key),
      },
    },
  },
)

include_cookbook 'aws-sdk-ruby'

file '/etc/ioi-ensure-onpremise-codedeploy-credentials.json' do
  content "#{node[:codedeploy_agent][:onpremises].to_json}\n"
  owner 'root'
  group 'root'
  mode  '0600'
end

remote_file '/usr/bin/ioi-ensure-onpremise-codedeploy-credentials' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/systemd/system/ioi-ensure-onpremise-codedeploy-credentials.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/systemd/system/ioi-ensure-onpremise-codedeploy-credentials.timer' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

execute 'systemctl daemon-reload; systemctl stop codedeploy-agent; systemctl start ioi-ensure-onpremise-codedeploy-credentials.service && systemctl start codedeploy-agent' do
  not_if 'test -e /etc/codedeploy-agent/conf/codedeploy.onpremises.yml'
end

service 'ioi-ensure-onpremise-codedeploy-credentials.timer' do
  action [:enable, :start]
end

