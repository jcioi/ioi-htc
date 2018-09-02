include_recipe 'variables.rb'

if node.dig(:cms, :variant) == 'onpremise' || %[dev practice].include?(node.dig(:cms, :cluster))
  include_recipe 'clientlb.rb' # CLB for cache-s3 & fproxy
end

##########

execute 'if systemctl is-enabled cms.target; then systemctl restart cms.target; fi' do
  action :nothing
end
# This affects cms-contestwebserver & cms-proxyservice

file '/etc/ioi-contest-id.env' do
  content "CMS_CONTEST_ID=#{node[:cms][:contest_id]}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[if systemctl is-enabled cms.target; then systemctl restart cms.target; fi]'
end

unless node[:hocho_ec2]
  file '/etc/cms_aws_access_key.env' do
    content "AWS_ACCESS_KEY_ID=#{node[:secrets].fetch(:"cms_#{node[:cms][:cluster]}_aws_access_key_id")}\nAWS_SECRET_ACCESS_KEY=#{node[:secrets].fetch(:"cms_#{node[:cms][:cluster]}_aws_secret_access_key")}\n"
    owner 'root'
    group 'root'
    mode  '0644'
  end
end

include_recipe 'user.rb'

include_recipe 'deps.rb'

include_recipe 'config.rb'
include_recipe 'cms.rb'
include_recipe 'utils.rb'
