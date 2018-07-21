node.reverse_merge!(
  cms: {
  },
)

node[:cms][:cluster] ||= node.dig(:hocho_ec2, :tags, :CmsCluster)
# Variant is for machine specific configuration purpose (e.g. onpremise)
case
when node[:hocho_ec2]
  node[:cms][:variant] ||= node.dig(:hocho_ec2, :tags, :CmsVariant)
when node[:hocho_ec2].nil?
  node[:cms][:variant] ||= 'onpremise'
end

node[:cms][:contest_id] ||= node[:contest_ids][node[:cms][:cluster]]

if node.dig(:cms, :variant) == 'onpremise' || node.dig(:cms, :cluster) == 'dev' # XXX:
  include_recipe 'clientlb.rb' # CLB for cache-s3 & fproxy
end

##########

user 'cmsuser' do
  uid 900
  shell '/bin/false'
  system_user true
end

if node.dig(:op_user, :name)
  opuser = node.dig(:op_user, :name)
  execute "usermod -a -G cmsuser #{opuser}" do
    not_if "id -zG #{opuser} | grep -z -q -x 900"
  end
end

# This affects cms-contestwebserver & cms-proxyservice
file '/etc/ioi-contest-id.env' do
  content "CMS_CONTEST_ID=#{node[:cms][:contest_id]}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

include_recipe 'deps.rb'
include_recipe 'config.rb'
include_recipe 'cms.rb'
include_recipe 'utils.rb'
