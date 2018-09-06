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
      rule_files: %w(/etc/prometheus/rules/*.yml),
      scrape_configs: [],
      alerting: {
        alert_relabel_configs: [],
        alertmanagers: [
          static_configs: [
            targets: %w(localhost:9093),
          ],
        ],
      },
    },
  },
)

directory '/etc/prometheus/files' do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/etc/prometheus/rules' do
  owner 'root'
  group 'root'
  mode  '0755'
end

%w(
  /etc/prometheus/rules/node.yml
  /etc/prometheus/rules/prometheus.yml
  /etc/prometheus/rules/cloudwatch.yml
  /etc/prometheus/rules/haproxy.yml
  /etc/prometheus/rules/cups.yml
  /etc/prometheus/rules/cms_system.yml
  /etc/prometheus/rules/cms_contest.yml
  /etc/prometheus/rules/aws_ec2.yml
  /etc/prometheus/rules/aws_elb.yml
  /etc/prometheus/rules/aws_lambda.yml
  /etc/prometheus/rules/aws_nat.yml
  /etc/prometheus/rules/aws_rds.yml
  /etc/prometheus/rules/aws_sqs.yml
  /etc/prometheus/rules/contestant_usb.yml
).each do |_|
  template _ do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :reload, 'service[prometheus.service]'
  end
end

scrape_configs = node[:prometheus][:config][:scrape_configs]

scrape_configs.push(
  job_name: :prometheus,
  static_configs: [
    targets: %w(
      localhost:9090
    ),
  ],
)
scrape_configs.push(
  job_name: :cloudwatch,
  scrape_interval: '2m',
  scrape_timeout: '2m',
  static_configs: [
    targets: %w(
      localhost:9106
      localhost:19106
    ),
    labels: {downalert: 'ignore'},
  ],
)
scrape_configs.push(
  job_name: :cloudwatch_h,
  scrape_interval: '1m',
  scrape_timeout: '1m',
  static_configs: [
    targets: %w(
      localhost:29106
    ),
    labels: {downalert: 'ignore'},
  ],
)
scrape_configs.push(
  job_name: :snmp,
  metrics_path: "/snmp",
  scrape_timeout: '19s',
  static_configs: [
    { targets: %w(rt-ngn-001.venue.ioi18.net), labels: {__param_module: 'if_mib_ifname'} },
    { targets: %w(rt-mdf-001.venue.ioi18.net), labels: {__param_module: 'if_mib_ifname'} },
    { targets: %w(rt-hall-001.venue.ioi18.net), labels: {__param_module: 'if_mib_ifname'} },
    { targets: %w(relay-001.venue.ioi18.net), labels: {__param_module: 'if_mib_ifname'} },
    { targets: %w(sw-hall.venue.ioi18.net), labels: {__param_module: 'if_mib_ifname'} },
    { targets: %w(wlc-001.venue.ioi18.net), labels: {__param_module: 'cisco_wlc'} },
  ],
  relabel_configs: [
    {source_labels: %w(__address__), target_label: '__param_target'},
    {source_labels: %w(__param_target), target_label: 'instance'},
    {target_label: '__address__', replacement: '127.0.0.1:9116'},
  ],
)
scrape_configs.push(
  job_name: :snmp_low,
  metrics_path: "/snmp",
  scrape_interval: '1m',
  scrape_timeout: '19s',
  static_configs: [
    { targets: %w(ups-hall-001.venue.ioi18.net), labels: {__param_module: 'apcups'} },
    { targets: %w(ups-hall-002.venue.ioi18.net), labels: {__param_module: 'apcups'} },
    { targets: %w(ups-mdf-001.venue.ioi18.net), labels: {__param_module: 'apcups'} },
  ],
  relabel_configs: [
    {source_labels: %w(__address__), target_label: '__param_target'},
    {source_labels: %w(__param_target), target_label: 'instance'},
    {target_label: '__address__', replacement: '127.0.0.1:9116'},
  ],
)
scrape_configs.push(
  job_name: :cms_contest,
  scheme: 'https',
  metrics_path: '/metrics/contest',
  scrape_interval: '30s',
  scrape_timeout: '20s',
  static_configs: [
    { targets: %w(admin-dev.ioi18.net:443), labels: {cms_cluster: 'dev'} },
    { targets: %w(admin-practice.ioi18.net:443), labels: {cms_cluster: 'practice'} },
    { targets: %w(admin.ioi18.net:443), labels: {cms_cluster: 'prd'} },
  ],
)
scrape_configs.push(
  job_name: :cms_system,
  scheme: 'https',
  metrics_path: '/metrics/system',
  scrape_interval: '30s',
  scrape_timeout: '20s',
  static_configs: [
    { targets: %w(admin-dev.ioi18.net:443), labels: {cms_cluster: 'dev'} },
    { targets: %w(admin-practice.ioi18.net:443), labels: {cms_cluster: 'practice'} },
    { targets: %w(admin.ioi18.net:443), labels: {cms_cluster: 'prd'} },
  ],
)
scrape_configs.push(
  job_name: :ioiconsole,
  scheme: 'https',
  metrics_path: '/metrics',
  scrape_interval: '5m',
  scrape_timeout: '3m',
  static_configs: [
    { targets: %w(console.ioi18.net:443), labels: {cms_cluster: 'prd'} },
  ],
)
scrape_configs.push(
  job_name: :ioiprint,
  scheme: 'http',
  metrics_path: '/metrics',
  scrape_interval: '1m',
  scrape_timeout: '30s',
  static_configs: [
    {
      targets: %w(print-001.apne1.aws.ioi18.net print-002.apne1.aws.ioi18.net),
      labels: {ioiprint_env: 'prd'}
    },
    {
      targets: %w(print-dev-001.apne1.aws.ioi18.net),
      labels: {ioiprint_env: 'dev'}
    },
  ],
)
scrape_configs.push(
  job_name: :contestant_ping,
  metrics_path: "/probe",
  scrape_interval: '6s',
  scrape_timeout: '5s',
  params: {
    module: %w(ping),
  },
  file_sd_configs: [
    {
      files: ['/etc/prometheus/files/contestant_node.json'],
      refresh_interval: '1m',
    },
  ],
  relabel_configs: [
    {source_labels: %w(__address__), target_label: '__param_target'},
    {source_labels: %w(__param_target), action: 'replace', regex: '^(.+?):.+$', replacement: '${1}', target_label: '__param_target'},
    {source_labels: %w(__param_target), target_label: 'instance'},
    {target_label: '__address__', replacement: '127.0.0.1:9115'},
  ],
)
scrape_configs.push(
  job_name: :contestant_nodes,
  metrics_path: "/metrics",
  file_sd_configs: [
    {
      files: ['/etc/prometheus/files/contestant_node.json'],
      refresh_interval: '1m',
    },
  ],
)
scrape_configs.push(
  job_name: :cmsworker_nodes,
  metrics_path: "/metrics",
  file_sd_configs: [
    {
      files: ['/etc/prometheus/files/cmsworker_node.json'],
      refresh_interval: '2m',
    },
  ],
)

host_jobs = [
  {
    job_name: 'node',
    port: 9100,
  },
  {
    job_name: 'unbound',
    role: '^dns-cache$',
    port: 9099,
    metrics_path: '/unbound_exporter/metrics',
  },
  {
    job_name: 'haproxy',
    role: 'cache-s3|rproxy-misc|rproxy-s3',
    port: 9099,
    metrics_path: '/haproxy_exporter/metrics',
  },
  {
    job_name: 'haproxy_cms',
    relabel_configs: [
      {source_labels: %w(cms_cluster), regex: '^dev$', action: 'keep'},
      {source_labels: %w(role), regex: 'cms-rankingwebserver', action: 'drop'},
    ],
    port: 9099,
    metrics_path: '/haproxy_exporter/metrics',
  },
  {
    job_name: 'varnish',
    role: 'cache-s3',
    port: 9099,
    metrics_path: '/varnish_exporter/metrics',
  },
  {
    job_name: 'kea',
    role: 'dhcp',
    port: 9099,
    metrics_path: '/kea_exporter/metrics',
  },
]

if node[:hocho_ec2]
  host_jobs.each do |job|
    scrape_configs.push(
      job_name: "ec2_#{job.fetch(:job_name)}",
      ec2_sd_configs: [
        {region: 'ap-northeast-1', port: job.fetch(:port)},
      ],
      metrics_path: job.fetch(:metrics_path, '/metrics'),
      relabel_configs: [
        {
          source_labels: ["__meta_ec2_instance_state"],
          regex: "^running$",
          action: "keep",
        },
        job.key?(:role) ? {
          source_labels: ["__meta_ec2_tag_Role"],
          regex: job.fetch(:role),
          action: "keep",
        } : nil,
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
          source_labels: ["__meta_ec2_tag_CmsCluster"],
          target_label: "cms_cluster",
        },
        *job[:relabel_configs],
      ].compact,
    )
  end
end
