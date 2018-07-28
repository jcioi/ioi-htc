include_recipe 'variables.rb'

if node.dig(:cms, :variant) == 'onpremise' || %[dev practice].include?(node.dig(:cms, :cluster))
  include_recipe 'clientlb.rb' # CLB for cache-s3 & fproxy
end

##########

# This affects cms-contestwebserver & cms-proxyservice
file '/etc/ioi-contest-id.env' do
  content "CMS_CONTEST_ID=#{node[:cms][:contest_id]}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

include_recipe 'user.rb'

include_recipe 'deps.rb'

include_recipe 'config.rb'
include_recipe 'cms.rb'
include_recipe 'utils.rb'
