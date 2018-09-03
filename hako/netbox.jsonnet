local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-0b2ee0b3e0127ce1d'];  // ecs-misc-internal-tools
local elbSecurityGroups = ['sg-0d6c8d7523b36c389'];  // elb-misc-internal-tools

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '1024',
    memory: '2048',
    elb_v2: {
      scheme: 'internal',
      vpc_id: utils.vpcId,
      health_check_path: '/',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
      ],
      subnets: utils.privateSubnets,
      security_groups: elbSecurityGroups,
    },
  },
  app: {
    image: 'ninech/netbox',  // v2.4.3
    env: {
      DB_NAME: 'netbox',
      DB_USER: 'netbox',
      DB_PASSWORD: utils.secret('netbox_db_password'),
      DB_HOST: 'db-netbox-001.c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com',
      REDIS_HOST: 'netbox.vozztv.0001.apne1.cache.amazonaws.com',
      SECRET_KEY: utils.secret('netbox_secret_key'),
      SUPERUSER_NAME: 'ioi',
      SUPERUSER_EMAIL: 'dummy@sorah.jp',
      SUPERUSER_PASSWORD: 'aikotoba',
      SUPERUSER_API_TOKEN: '8cce55866c538b2e8996ec1d11716645f4af33fc',
    },
    mount_points: [
      {
        source_volume: 'static',
        container_path: '/opt/netbox/netbox/static',
      },
    ],
    docker_labels: {
      'net.ioi18.hako.health-check-path': '/',
    },
    log_configuration: utils.awsLogs('app'),
  },
  additional_containers: {
    front: front.container {
      mount_points: [
        {
          source_volume: 'static',
          container_path: '/opt/netbox/netbox/static',
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
    utils.createLogGroups(),
    front.script.defaultOmniauth {
      backend_port: '8001',
      locations: {
        '/': {
          https_type: 'always',
        use_omniauth: true,
        },
        '/static': {
          https_type: 'always',
          root: '/opt/netbox/netbox',
          use_omniauth: true,
        },
      },
    },
  ],
}
