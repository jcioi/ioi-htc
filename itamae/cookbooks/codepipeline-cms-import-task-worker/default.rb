node.reverse_merge!(
  codepipeline_cms_import_task_worker: {
    aws_region: node.fetch(:hocho_ec2)[:placement][:availability_zone][0...-1],
  },
)

include_cookbook 'cms::variables'
include_cookbook 'aws-sdk-ruby'

remote_file '/usr/bin/ioi-codepipeline-cms-import-task-worker.rb' do
  owner 'root'
  group 'root'
  mode  '0755'
end

file '/etc/ioi-codepipeline-cms-import-task-worker.env' do
  content "AWS_REGION=#{node[:codepipeline_cms_import_task_worker].fetch(:aws_region)}\nCMS_CLUSTER=#{node.fetch(:cms).fetch(:cluster)}"
  owner 'cmsuser'
  group 'cmsuser'
  mode  '0600'
end

remote_file '/etc/systemd/system/ioi-codepipeline-cms-import-task-worker.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'ioi-codepipeline-cms-import-task-worker.service' do
  action [:enable, :start]
end
