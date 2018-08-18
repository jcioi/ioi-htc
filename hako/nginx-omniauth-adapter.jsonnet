local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-024c08f00c066c00f'];  // nginx-omniauth-adapter
local elbSecurityGroups = ['sg-06f0c7cda02530a27'];  // elb-nginx-omniauth-adapter

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '512',
    memory: '1024',
    desired_count: 2,
    elb_v2: {
      vpc_id: utils.vpcId,
      scheme: 'internal',
      subnets: utils.privateSubnets,
      security_groups: elbSecurityGroups,
      health_check_path: '/site/sha',
      listeners: [
        {
          port: 80,
          protocol: 'HTTP',
        },
        {
          port: 443,
          protocol: 'HTTPS',
          certificate_arn: 'arn:aws:acm:ap-northeast-1:550372229658:certificate/61e52d9d-c7cf-4f76-8f0f-72f9ccd92564',
        },
      ],
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
    image: utils.ecrRepository('ioi18-nginx-omniauth-adapter'),
    env: {
      RACK_ENV: 'production',
      SECRET_KEY_BASE: utils.secret('nginx_omniauth_adapter_session_secret'),
      NGX_OMNIAUTH_SECRET: utils.secret('nginx_omniauth_adapter_secret'),
      GITHUB_KEY: utils.secret('nginx_omniauth_adapter_github_key'),
      GITHUB_SECRET: utils.secret('nginx_omniauth_adapter_github_secret'),
      GITHUB_ACCESS_TOKEN: utils.secret('github_access_token'),
    },
    log_configuration: utils.awsLogs('app'),
  },
  additional_containers: {
    front: front.container,
  },
  scripts: [
    utils.codebuildTag('ioi18-infra-nginx-omniauth-adapter-dpl'),
    utils.createLogGroups(),
    front.script.defaultPublic {
      backend_port: '8080',
    },
  ],
}
