local front = import 'lib/front.libsonnet';
local utils = import 'lib/utils.libsonnet';

local appCommon = import 'ioi-console/common.libsonnet';

appCommon {
  scheduler+: {
    cpu: '1024',
    memory: '2048',
    desired_count: 20,
  },
  app+: {
    env+: {
      IOI_SHORYUKEN_CONCURRENCY: '15',
    },
    command: ['bundle', 'exec', 'shoryuken', 'start', '-R', '-C', '/app/config/shoryuken.yml'],
  },
  additional_containers+: {
  },
  scripts+: [
  ],
}
