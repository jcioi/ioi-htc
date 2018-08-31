node.reverse_merge!(
  ioi_cms_export_submissions: {
    aws_region: node.fetch(:hocho_ec2)[:placement][:availability_zone][0...-1],
  },
)

include_cookbook 'cms::variables'
include_cookbook 'awscli'

remote_file '/usr/bin/ioi-cms-export-submissions.sh' do
  owner 'root'
  group 'root'
  mode  '0755'
end

cluster = node[:cms][:cluster]

file '/etc/ioi-cms-export-submissions.env' do
  content <<EOF
AWS_REGION=#{node[:ioi_cms_export_submissions].fetch(:aws_region)}
AWS_ACCESS_KEY_ID=#{node[:secrets].fetch("cms_export_#{cluster}_aws_access_key_id")}
AWS_SECRET_ACCESS_KEY=#{node[:secrets].fetch("cms_export_#{cluster}_aws_secret_access_key")}
ZIP_DESTINATION=#{node[:ioi_cms_export_submissions].fetch('bucket')}
TZ=#{node[:ioi_cms_export_submissions].fetch('timezone')}
EOF
  owner 'cmsuser'
  group 'cmsuser'
  mode  '0600'
end

remote_file '/etc/systemd/system/ioi-cms-export-submissions.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/systemd/system/ioi-cms-export-submissions.timer' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'ioi-cms-export-submissions.timer' do
  action [:enable, :start]
end
