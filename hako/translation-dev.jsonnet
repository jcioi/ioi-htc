local secretProvider = std.native('provide.itamae_secrets');
local secret(name) = secretProvider(std.toString({ base_dir: '../itamae/secrets' }), name);

local appId = std.extVar('appId');

local region = 'ap-northeast-1';
local vpc = 'vpc-03eed691a6a5a03b2';
local publicSubnets = ['subnet-05ef7963c73bdf728', 'subnet-06848ecd38958c144', 'subnet-0e12d73c1fb79989a'];
local privateSubnets = ['subnet-004f53c13cc873a5d', 'subnet-02f8ccb28e04b3f66', 'subnet-041823884cb44af44'];
local taskSecurityGroups = ['sg-0b97c2a51099cdf2a']; // translation-dev
local elbSecurityGroups = ['sg-035c00f22c7fe5429']; // elb-translation-dev
local registry = '550372229658.dkr.ecr.ap-northeast-1.amazonaws.com';

local awslogs = {
  log_driver: 'awslogs',
  options: {
    'awslogs-group': std.format('/ecs/%s', appId),
    'awslogs-region': region,
    'awslogs-stream-prefix': 'ecs',
  },
};

{
  scheduler: {
    type: 'ecs',
    region: region,
    cluster: 'ioi18',
    desired_count: 1,
    task_role_arn: null,
    execution_role_arn: 'arn:aws:iam::550372229658:role/ecsTaskExecutionRole',
    cpu: '1024',
    memory: '2048',
    requires_compatibilities: ['FARGATE'],
    network_mode: 'awsvpc',
    launch_type: 'FARGATE',
    network_configuration: {
      awsvpc_configuration: {
        subnets: privateSubnets,
        security_groups: taskSecurityGroups,
        assign_public_ip: 'DISABLED',
      },
    },
    elb_v2: {
      vpc_id: vpc,
      health_check_path: '/',
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
      subnets: publicSubnets,
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
    image: registry + '/ioi18-translation',
    cpu: 1024,
    memory: 2048,
    env: {
      DB_HOST: 'translation-dev-db.c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com',
      DB_USER: 'ioitrans',
      DB_PASSWORD: secret('db_ioitrans_password'),
      DB_NAME: 'ioitrans',
      REDIS_HOST: 'ioitrans-dev-redis.vozztv.0001.apne1.cache.amazonaws.com',
      REDIS_DB: '1',
      GUNICORN_WORKERS: '2',
    },
    mount_points: [
      {
        source_volume: 'static',
        container_path: '/usr/src/app/static',
      },
    ],
    log_configuration: awslogs,
  },
  additional_containers: {
    front: {
      image_tag: registry + '/ioi18-translation-front:staging',
      env: {
        BACKEND_HOST: 'localhost',
        BACKEND_PORT: '8000',
      },
      mount_points: [
        {
          source_volume: 'static',
          container_path: '/usr/src/app/static',
          read_only: true,
        },
      ],
      port_mappings: [
        {
          container_port: 80,
          host_port: 80,
          protocol: 'tcp',
        },
      ],
      log_configuratipon: awslogs,
    },
  },
  volumes: {
    static: {
    },
  },
}
