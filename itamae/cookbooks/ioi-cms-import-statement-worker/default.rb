node.reverse_merge!(
  ioi_cms_import_statement_worker: {
    aws_region: node.fetch(:hocho_ec2)[:placement][:availability_zone][0...-1],
  },
)

include_cookbook 'cms::variables'
include_cookbook 'aws-sdk-ruby'

remote_file '/usr/bin/ioi-cms-import-statement-worker.rb' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :restart, 'service[ioi-cms-import-statement-worker.service]'
end

file '/etc/ioi-cms-import-statement-worker.env' do
  content <<EOF
AWS_REGION=#{node[:ioi_cms_import_statement_worker].fetch(:aws_region)}
QUEUE_NAME=cms-statement-#{node.fetch(:cms).fetch(:cluster)}
EOF
  owner 'cmsuser'
  group 'cmsuser'
  mode  '0600'
end

remote_file '/etc/systemd/system/ioi-cms-import-statement-worker.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'ioi-cms-import-statement-worker.service' do
  action [:enable, :start]
end
