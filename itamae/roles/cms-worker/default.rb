include_role 'base'
include_cookbook 'cms'
include_cookbook 'compilers'
include_cookbook 'cms::isolate'

if node.dig(:cms, :variant) == 'onpremise'
  node.reverse_merge!(
    codedeploy_agent: {
      proxy_uri: 'http://fproxy.ioi18.net:80'
    },
  )
end

include_cookbook 'codedeploy-agent'
include_cookbook 'codedeploy-agent::onpremises' if node.dig(:cms, :variant) == 'onpremise'

service 'cms-resourceservice.service' do
  action [:enable]
end

service 'cms-worker.service' do
  action [:enable]
end
