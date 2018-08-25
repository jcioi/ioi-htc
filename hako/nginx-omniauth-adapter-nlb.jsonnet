local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';
local taskSecurityGroups = ['sg-095df5d86ca6c95cf'];  // nginx-omniauth-adapter-nlb

{
  scheduler: utils.fargateScheduler(taskSecurityGroups) {
    cpu: '512',
    memory: '1024',
    desired_count: 2,
    elb_v2: {
      type: 'network',
      vpc_id: utils.vpcId,
      scheme: 'internal',
      listeners: [
        {
          port: 80,
          protocol: 'TCP',
        },
      ],
      subnets: utils.privateSubnets,
      container_name: 'front',
      container_port: 80,
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
