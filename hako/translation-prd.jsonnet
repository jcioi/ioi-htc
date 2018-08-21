local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-068276f7d1fc59889'];  // translation
local elbSecurityGroups = ['sg-0d628db6dcf52657f'];  // elb-translation

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '1024',
    memory: '2048',
    task_role_arn: utils.iamRole('EcsTranslation'),
    elb_v2: {
      vpc_id: utils.vpcId,
      scheme: 'internal',
      health_check_path: '/healthcheck',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:550372229658:certificate/0b30594a-ef9d-4268-9d7e-479d28308b66',
        },
      ],
      subnets: utils.privateSubnets,
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
      SECRET_KEY: utils.secret('translation_secret_key_prd'),
      DB_HOST: 'translation-db.c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com',
      DB_USER: 'ioitrans',
      DB_PASSWORD: utils.secret('db_ioitrans_password'),
      DB_NAME: 'ioitrans',
      REDIS_HOST: 'translation-prd.vozztv.0001.apne1.cache.amazonaws.com',
      REDIS_DB: '1',
      S3_BUCKET: 'ioi18-translation-files-prd',
      SQS_QUEUE_NAME: 'cms-statement-prd',
      SQS_REGION_NAME: 'ap-northeast-1',
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
