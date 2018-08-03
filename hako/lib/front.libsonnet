local utils = import './utils.libsonnet';
local tag = 'a25049daac81226ad8a2849d61b960e83bcf808d';

{
  container: {
    image_tag: std.format('%s:%s', [utils.ecrRepository('ioi18-hako-front'), tag]),
    log_configuration: utils.awsLogs('front'),
  },
  script: {
    local default = {
      type: 'ioi_nginx',
      backend_host: 'localhost',
      s3: {
        region: 'ap-northeast-1',
        bucket: 'ioi18-infra',
        prefix: 'hako/front-config',
      },
    },
    defaultPublic: default {
      locations: {
        '/': {
          https_type: 'always',
        },
      },
    },
    defaultPublicHttp: default {
      locations: {
        '/': {
          https_type: null,
        },
      },
    },
    defaultOmniauth: default {
      locations: {
        '/': {
          https_type: 'always',
          use_omniauth: true,
        },
      },
    },
  },
}
