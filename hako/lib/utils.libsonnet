local secretProvider = std.native('provide.itamae_secrets');
local secret(name) = secretProvider(std.toString({ base_dir: '../itamae/secrets' }), name);

local privateSubnets = ['subnet-004f53c13cc873a5d', 'subnet-02f8ccb28e04b3f66', 'subnet-041823884cb44af44'];


// local region = 'ap-northeast-1';
local vpc = 'vpc-03eed691a6a5a03b2';
local publicSubnets = ['subnet-05ef7963c73bdf728', 'subnet-06848ecd38958c144', 'subnet-0e12d73c1fb79989a'];

{
  vpcId: vpc,
  publicSubnets: publicSubnets,
  secret(name):: secret(name),
  ecrRepository(name):: std.format('550372229658.dkr.ecr.ap-northeast-1.amazonaws.com/%s', name),

  fargateScheduler(securityGroups):: {
    type: 'ecs',
    region: 'ap-northeast-1',
    cluster: 'ioi18',
    desired_count: 1,
    task_role_arn: null,
    execution_role_arn: 'arn:aws:iam::550372229658:role/ecsTaskExecutionRole',
    cpu: '256',
    memory: '1024',
    requires_compatibilities: ['FARGATE'],
    network_mode: 'awsvpc',
    launch_type: 'FARGATE',
    network_configuration: {
      awsvpc_configuration: {
        subnets: privateSubnets,
        security_groups: securityGroups,
        assign_public_ip: 'DISABLED',
      },
    },
  },

  awsLogs(name):: {
    log_driver: 'awslogs',
    options: {
      'awslogs-group': std.format('/ecs/%s_%s', [std.extVar('appId'), name]),
      'awslogs-region': 'ap-northeast-1',
      'awslogs-stream-prefix': 'ecs',
    },
  },

  createLogGroups():: {
    type: 'create_aws_cloud_watch_logs_log_group',
  },
}
