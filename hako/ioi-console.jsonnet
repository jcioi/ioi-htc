local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local elbSecurityGroups = ['sg-0cd32a6bd67af4855'];  // elb-ioi-console

local appCommon = import 'ioi-console/common.libsonnet';

appCommon {
  scheduler+: {
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
  app+: {
    env+: {
    },
  },
  additional_containers+: {
    front: front.container,
  },
  scripts+: [
    front.script.defaultPublic {
      backend_port: '8080',
    },
  ],
}
