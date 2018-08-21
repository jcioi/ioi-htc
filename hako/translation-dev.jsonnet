local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-0b97c2a51099cdf2a'];  // translation-dev
local elbSecurityGroups = ['sg-035c00f22c7fe5429'];  // elb-translation-dev

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '1024',
    memory: '2048',
    task_role_arn: utils.iamRole('EcsTranslationDev'),
    elb_v2: {
      vpc_id: utils.vpcId,
      health_check_path: '/healthcheck',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:550372229658:certificate/f322e479-c94f-4683-b20f-17a2e652fe64',
        },
      ],
      subnets: utils.publicSubnets,
      security_groups: elbSecurityGroups,
      // load_balancer_attributes: {
      //   'access_logs.s3.enabled': 'true',
      //   'access_logs.s3.bucket': 'hako-access-logs',
      //   'access_logs.s3.prefix': std.format('hako-%s', appId),
      //   'idle_timeout.timeout_seconds': '5',
      // },
      // target_group_attributes: {
      //   'deregistration_delay.timeout_seconds': '20',
      // },
    },
  },
  app: {
    image: utils.ecrRepository('ioi18-translation'),
    cpu: 512,
    memory: 1024,
    env: {
      SECRET_KEY: utils.secret('translation_secret_key'),
      DB_HOST: 'translation-dev-db.c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com',
      DB_USER: 'ioitrans',
      DB_PASSWORD: utils.secret('db_ioitrans_password'),
      DB_NAME: 'ioitrans',
      REDIS_HOST: 'ioitrans-dev-redis.vozztv.0001.apne1.cache.amazonaws.com',
      REDIS_DB: '1',
      S3_BUCKET: 'ioi18-translation-files-dev',
      SQS_QUEUE_NAME: 'cms-statement-dev',
      SQS_REGION_NAME: 'ap-northeast-1',
      PRINT_SYSTEM_URL: 'https://print-dev.ioi18.net',
      GUNICORN_WORKERS: '2',
    },
    mount_points: [
      {
        source_volume: 'static',
        container_path: '/usr/src/app/static',
      },
    ],
    docker_labels: {
      'net.ioi18.hako.health-check-path': '/healthcheck',
    },
    log_configuration: utils.awsLogs('app'),
  },
  additional_containers: {
    front: front.container {
      mount_points: [
        {
          source_volume: 'static',
          container_path: '/usr/src/app/static',
          read_only: true,
        },
      ],
    },
  },
  volumes: {
    static: {
    },
  },
  scripts: [
    utils.codebuildTag('ioi18-translation'),
    utils.createLogGroups(),
    front.script.defaultPublic {
      backend_port: '8000',
      locations: {
        '/': {
          https_type: 'always',
        },
        '/static': {
          https_type: 'always',
          root: '/usr/src/app',
        },
        '/s3proxy': {
          raw: |||
            internal;
            set $s3url $upstream_http_location;
          |||,
          proxy_set_header: {
            Host: '$proxy_host',
            Authorization: '',
          },
          proxy_pass: '$s3url',
          add_header: {
            'Cache-Control': 'private, no-cache',
          },
        },
      },
    },
  ],
}
