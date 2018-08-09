local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-0b2ee0b3e0127ce1d'];  // ecs-misc-internal-tools
local elbSecurityGroups = ['sg-0e0b275eb52cde309'];  // elb-misc-internal-tools-public

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '256',
    memory: '512',
    task_role_arn: utils.iamRole('EcsAwsTools'),
    elb_v2: {
      vpc_id: utils.vpcId,
      health_check_path: '/site/sha',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:550372229658:certificate/bb993e86-1acc-4182-9f0d-0d9a371ecd67',
        },
      ],
      subnets: utils.publicSubnets,
      security_groups: elbSecurityGroups,
    },
  },
  app: {
    image: utils.ecrRepository('ioi18-awstools'),
    cpu: 256,
    memory: 256,
    env: {
      RACK_ENV: 'production',
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
    utils.codebuildTag('ioi18-awstools'),
    utils.createLogGroups(),
    front.script.defaultOmniauth {
      backend_port: '8080',
    },
  ],
}
