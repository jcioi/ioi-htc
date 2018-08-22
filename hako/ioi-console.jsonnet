local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-07cbf45909312285a'];  // ioi-console
local elbSecurityGroups = ['sg-0cd32a6bd67af4855'];  // elb-ioi-console

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '512',
    memory: '1024',
    desired_count: 2,
    task_role_arn: utils.iamRole('EcsIoiConsole'),
    elb_v2: {
      vpc_id: utils.vpcId,
      scheme: 'internal',
      health_check_path: '/site/sha',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:550372229658:certificate/d849fcde-6e59-4962-b1a2-768af878591a',
        },
      ],
      subnets: utils.privateSubnets,
      security_groups: elbSecurityGroups,
    },
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
    },
    mount_points: [
    ],
    docker_labels: {
      'net.ioi18.hako.health-check-path': '/site/sha',
    },
    log_configuration: utils.awsLogs('app'),
  },
  additional_containers: {
    front: front.container,
  },
  volumes: {
    static: {
    },
  },
  scripts: [
    utils.codebuildTag('ioi18-ioi_console'),
    utils.createLogGroups(),
    front.script.defaultPublic {
      backend_port: '8080',
    },
  ],
}
