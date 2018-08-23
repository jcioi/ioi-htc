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
    cloudwatch_exporter: {
      configs: {
        'us-east-1' => {
          port: 19106,
          config: {
            region: 'us-east-1',
            metrics: [
              [{}].flat_map do |stats_opt|
                %w(
                  4xxErrorRate
                  5xxErrorRate
                  BytesDownloaded
                  BytesUploaded
                  Requests
                  TotalErrorRate
                ).map do |metric|
                  { aws_namespace: 'AWS/CloudFront', aws_dimensions: %w(DistributionId), aws_metric_name: metric, period_seconds: 300 }.merge(stats_opt)
                end
              end,
            ].flatten,
          },
        },
        'ap-northeast-1' => {
          port: 9106,
          config: {
            region: 'ap-northeast-1',
            metrics: [
              [{aws_statistics: %w(Average Minimum Maximum)}, {aws_extended_statistics: %w(p50 p95 p99)}].flat_map do |stats_opt|
                %w(
                  TargetResponseTime
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ApplicationELB',
                    aws_metric_name: metric,
                    aws_dimensions: %w(LoadBalancer AvailabilityZone TargetGroup),
                    period_seconds: 300,
                  }.merge(stats_opt)
                end
              end,
              %w(
                HTTPCode_Target_5XX_Count
                HTTPCode_Target_4XX_Count
                HTTPCode_Target_3XX_Count
                HTTPCode_Target_2XX_Count
                HTTPCode_ELB_5XX_Count
                HTTPCode_ELB_4XX_Count
              ).map do |metric|
                {
                  aws_namespace: 'AWS/ApplicationELB',
                  aws_metric_name: metric,
                  aws_dimensions: %w(LoadBalancer AvailabilityZone TargetGroup),
                  period_seconds: 300,
                  aws_statistics: %w(Sum)
                }
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}, {aws_extended_statistics: %w(p50 p95 p99)}].flat_map do |stats_opt|
                %w(
                  Latency
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ELB',
                    aws_metric_name: metric,
                    aws_dimensions: %w(LoadBalancerName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              %w(
                HTTPCode_Backend_5XX
                HTTPCode_Backend_4XX
                HTTPCode_Backend_3XX
                HTTPCode_Backend_2XX
                HTTPCode_ELB_5XX
                HTTPCode_ELB_4XX
              ).map do |metric|
                {
                  aws_namespace: 'AWS/ELB',
                  aws_metric_name: metric,
                  aws_dimensions: %w(LoadBalancerName),
                  period_seconds: 300,
                  aws_statistics: %w(Sum)
                }
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  VolumeReadBytes
                  VolumeIdleTime
                  VolumeReadOps
                  BurstBalance
                  VolumeQueueLength
                  VolumeWriteBytes
                  VolumeWriteOps
                  VolumeTotalReadTime
                  VolumeTotalWriteTime
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/EBS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(VolumeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  CPUCreditBalance
                  CPUCreditUsage
                  CPUSurplusCreditBalance
                  CPUSurplusCreditsCharged
                  CPUUtilization
                  DiskReadBytes
                  DiskReadOps
                  DiskWriteBytes
                  DiskWriteOps
                  NetworkOut
                  NetworkPacketsIn
                  NetworkPacketsOut
                  StatusCheckFailed
                  StatusCheckFailed_Instance
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/EC2',
                    aws_metric_name: metric,
                    aws_dimensions: %w(InstanceId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(SampleCount Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  MemoryUtilization
                  CPUUtilization
                  MemoryUtilization
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ECS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(ServiceName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  NewConnections
                  CacheMisses
                  Reclaimed
                  Evictions
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ElastiCache',
                    aws_metric_name: metric,
                    aws_dimensions: %w(CacheClusterId CacheNodeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ReplicationLag
                  CurrConnections
                  CPUUtilization
                  CurrItems
                  ReplicationBytes
                  FreeableMemory
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ElastiCache',
                    aws_metric_name: metric,
                    aws_dimensions: %w(CacheClusterId CacheNodeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  Errors
                  Invocations
                  Throttles
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/Lambda',
                    aws_metric_name: metric,
                    aws_dimensions: %w(FunctionName Resource),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ConcurrentExecutions
                  UnreservedConcurrentExecutions
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/Lambda',
                    aws_metric_name: metric,
                    aws_dimensions: %w(FunctionName Resource),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ConnectionAttemptCount
                  IdleTimeoutCount
                  BytesInFromDestination
                  PacketsDropCount
                  ConnectionEstablishedCount
                  PacketsOutToDestination
                  ErrorPortAllocation
                  BytesOutToSource
                  BytesInFromSource
                  PacketsOutToSource
                  BytesOutToDestination
                  PacketsInFromDestination
                  ActiveConnectionCount
                  PacketsInFromSource
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/NATGateway',
                    aws_metric_name: metric,
                    aws_dimensions: %w(NatGatewayId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  CPUCreditBalance
                  CPUCreditUsage
                  CPUUtilization
                  DatabaseConnections
                  DBLoad
                  DBLoadCPU
                  DBLoadNonCPU
                  Deadlocks
                  DiskQueueDepth
                  EngineUptime
                  FreeableMemory
                  FreeLocalStorage
                  FreeStorageSpace
                  MaximumUsedTransactionIDs
                  NetworkReceiveThroughput
                  NetworkThroughput
                  NetworkTransmitThroughput
                  OldestReplicationSlotLag
                  RDSToAuroraPostgreSQLReplicaLag
                  ReadIOPS
                  ReadLatency
                  ReadThroughput
                  ReplicationSlotDiskUsage
                  SwapUsage
                  TransactionLogsDiskUsage
                  TransactionLogsGeneration
                  WriteIOPS
                  WriteLatency
                  WriteThroughput
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/RDS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(DBClusterIdentifier Role DBInstanceIdentifier),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Average Maximum)}].flat_map do |stats_opt|
                %w(
                  NumberOfObjects
                  BucketSizeBytes
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/S3',
                    aws_metric_name: metric,
                    aws_dimensions: %w(BucketName),
                    period_seconds: 86400,
                    set_timestamp: false
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  NumberOfMessagesSent
                  NumberOfEmptyReceives
                  NumberOfMessagesDeleted
                  NumberOfMessagesReceived
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/SQS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(QueueName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  SentMessageSize
                  ApproximateNumberOfMessagesVisible
                  ApproximateAgeOfOldestMessage
                  ApproximateNumberOfMessagesNotVisible
                  ApproximateNumberOfMessagesDelayed
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/SQS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(QueueName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  TunnelDataIn
                  TunnelState
                  TunnelDataOut
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/VPN',
                    aws_metric_name: metric,
                    aws_dimensions: %w(TunnelIpAddress VpnId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
            ].flatten,
          },
        },
      },
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
scrape_configs.push(
  job_name: :cloudwatch,
  scrape_interval: '5m',
  static_configs: [
    targets: %w(
      localhost:9106
      localhost:19106
    ),
  ],
)

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
