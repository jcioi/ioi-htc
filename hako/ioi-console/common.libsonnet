local utils = import '../lib/utils.libsonnet';
local taskSecurityGroups = ['sg-07cbf45909312285a'];  // ioi-console
local elbSecurityGroups = ['sg-0cd32a6bd67af4855'];  // elb-ioi-console

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '512',
    memory: '1024',
    desired_count: 2,
    task_role_arn: utils.iamRole('EcsIoiConsole'),
  },
  app: {
    image: utils.ecrRepository('ioi18-console'),
    env: {
      RACK_ENV: 'production',
      RAILS_ENV: 'production',
      RAILS_SERVE_STATIC_FILES: '1',
      RAILS_LOG_TO_STDOUT: '1',
      PORT: '8080',
      DATABASE_URL: std.format('postgresql://ioiconsole:%s@ioi-console.cluster-c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com/ioi_console', utils.secret('ioi_console_db_password')),
      SECRET_KEY_BASE: utils.secret('ioi_console_secret_key_base'),
      GITHUB_ACCESS_TOKEN: utils.secret('github_access_token'),
      GITHUB_CLIENT_ID: utils.secret('ioi_console_github_client_id'),
      GITHUB_CLIENT_SECRET: utils.secret('ioi_console_github_client_secret'),
      GITHUB_TEAMS: '2589499',  // jcioi/ioi18
      SENTRY_DSN: 'https://7ac3f763910a4424a693bfc69eece15b:8e0a54e046fb4adf9f1e0e5c9ab942ab@sentry.io/1267051',
      IOIPRINT_URL: 'https://print.ioi18.net',
      IOI_SQS_REGION: 'ap-northeast-1',
      IOI_SQS_QUEUE_PREFIX: 'ioi18-console_prd',
      // IOI_SHORYUKEN_QUEUE: '',
      // IOI_SHORYUKEN_CONCURRENCY: '',
      IOI_S3_LOG_REGION: 'ap-northeast-1',
      IOI_S3_LOG_BUCKET: 'ioi18-console',
      IOI_S3_LOG_PREFIX: 'remote-task/log/',
      IOI_SSM_PROCESS_EVENTS: '1',
      IOI_SSM_REGION: 'ap-northeast-1',
      IOI_SSM_LOG_S3_REGION: 'ap-northeast-1',
      IOI_SSM_LOG_S3_BUCKET: 'ioi18-console',
      IOI_SSM_LOG_S3_PREFIX: 'remote-task/ssm-log/',
      IOI_SSM_SCRATCH_S3_REGION: 'ap-northeast-1',
      IOI_SSM_SCRATCH_S3_BUCKET: 'ioi18-console',
      IOI_SSM_SCRATCH_S3_PREFIX: 'remote-task/scratch/',
      IOI_IPAM_LEASES_S3_REGION: 'ap-northeast-1',
      IOI_IPAM_LEASES_S3_BUCKET: 'ioi18-infra',
      IOI_IPAM_LEASES_S3_KEY: 'dhcp/leases/dhcp-001.4',
      IOI_IPAM_LEASES_TARGET_IDS: '320',
      IOI_IPAM_SSH_USER: 'ioim',
      IOI_IPAM_SSH_PASSWORD: utils.secret('cisco_ssh_password'),
      IOI_IPAM_SWITCH_HOSTS: 'sw-ara-011.venue.ioi18.net,sw-ara-021.venue.ioi18.net,sw-ara-031.venue.ioi18.net,sw-ara-041.venue.ioi18.net',
    },
    mount_points: [
    ],
    docker_labels: {
      'net.ioi18.hako.health-check-path': '/site/sha',
    },
    log_configuration: utils.awsLogs('app'),
  },
  additional_containers: {
  },
  volumes: {
  },
  scripts: [
    utils.codebuildTag('ioi18-ioi_console'),
    utils.createLogGroups(),
  ],
}
