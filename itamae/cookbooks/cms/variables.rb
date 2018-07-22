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
