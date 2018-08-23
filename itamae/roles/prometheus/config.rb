node.reverse_merge!(
  prometheus: {
    config: {
      global: {
        scrape_interval: '20s',
        scrape_timeout: '10s',
        evaluation_interval: '20s',
        external_labels: {
        },
      },
      rule_files: nil,#%w(/etc/prometheus/rules/*),
      scrape_configs: [],
    },
  },
)

scrape_configs = node[:prometheus][:config][:scrape_configs]

scrape_configs.push(
  job_name: :prometheus,
  static_configs: [
    targets: %w(
      localhost:9090
    ),
  ],
)
#scrape_configs.push(
#  job_name: :cloudwatch,
#  scrape_interval: '5m',
#  static_configs: [
#    targets: %w(
#      localhost:9106
#    ),
#  ],
#)

if node[:hocho_ec2]
  scrape_configs.push(
    job_name: :ec2_node,
    ec2_sd_configs: [
      {region: 'ap-northeast-1', port: 9100},
    ],
    relabel_configs: [
      {
        source_labels: ["__meta_ec2_instance_state"],
        regex: "^running$",
        action: "keep",
      },
      {
        source_labels: ["__meta_ec2_tag_Name"],
        target_label: "instance",
      },
      {
        source_labels: ["__meta_ec2_tag_Role"],
        target_label: "role",
      },
      {
        source_labels: ["__meta_ec2_tag_Status"],
        target_label: "status",
      },
      {
        source_labels: ["__meta_ec2_instance_type"],
        target_label: "instance_type",
      },
      {
        source_labels: ["__meta_ec2_availability_zone"],
        target_label: "availability_zone",
      },
      {
        source_labels: ["__meta_ec2_vpc_id"],
        target_label: "vpc_id",
      },
      {
        source_labels: ["__meta_ec2_CmsCluster"],
        target_label: "cms_cluster",
      },
    ],
  )
end
