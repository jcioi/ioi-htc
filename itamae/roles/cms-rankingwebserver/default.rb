# CMS' RankingWebServer is a part of CMS, but it's designed to be isolated from other components.
# This receives ranking data from ProxyService and persist them into a local disk, and serves a public
# scoreboard of the contest.

node.reverse_merge!(
  cms: {
    ranking_config: {
      log_dir: "/var/log/cms",
      lib_dir: "/var/lib/cms",

      bind_address: '127.0.0.1',
      http_port: 8888,
      # Don't worry for leaving this in plaintext (Write access is resricted in HTTP layer)
      username: 'citrus',
      password: 'aikotoba',
    },
  },
  nginx: {
    default_conf: false, # For accessing an app using hostname from ProxyService
  },
)

include_role 'base'

# Minimum installation due to the isolation explained above
include_cookbook 'cms::variables'
include_cookbook 'cms::user'
include_cookbook 'cms::deps'
include_cookbook 'cms::cms'

include_cookbook 'nginx'
include_cookbook 'codedeploy-agent'

template '/etc/nginx/conf.d/ranking.conf' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :run, 'execute[nginx try-reload]'
end

file '/etc/cms.ranking.conf' do
  content "#{node[:cms][:ranking_config].to_json}\n"
  owner 'root'
  group 'cmsuser'
  mode  '0640'
end

service 'cms-rankingwebserver.service' do
  action [:enable]
end

service 'nginx.service' do
  action [:enable]
end
