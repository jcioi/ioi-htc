node.reverse_merge!(
  prometheus: {
    cloudwatch_exporter: {
      version: 'cloudwatch_exporter-0.5.0',
      configs: {
        # region => {port:, config:}
      },
    },
  },
)

include_cookbook 'docker'

template '/usr/bin/prometheus-cloudwatch-exporter' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template "/etc/systemd/system/prometheus-cloudwatch-exporter@.service" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

node[:prometheus][:cloudwatch_exporter][:configs].each do |region, spec|
  file "/etc/prometheus/cloudwatch.#{region}.yml" do
    content "# port=#{spec.fetch(:port, 9106)}\n#{spec.fetch(:config).to_json}\n"
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :restart, "service[prometheus-cloudwatch-exporter@#{region}.service]", :immediately
  end

  service "prometheus-cloudwatch-exporter@#{region}.service" do
    action [:enable, :start]
  end
end

