node.reverse_merge!(
  cms: {
  },
)

node[:cms][:cluster] ||= node.dig(:hocho_ec2, :tags, :CmsCluster)
node[:cms][:contest_id] ||= node[:contest_ids][node[:cms][:cluster]]

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
