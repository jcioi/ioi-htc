node.reverse_merge!(
  prometheus: {
    alertmanager: {
      mounts: %w(/mnt/vol/alertmanager-data:/data),
      config: {
        global: {
          resolve_timeout: '5m',
        },
        route: {
          routes: [
            {
              group_by: ['alertname', 'instance'],
              group_wait: '12s',
              group_interval: '12s',
              repeat_interval: '1h',
              receiver: 'slack-alert-contestants',
              match: [ {"job": "contestant_nodes"} ],
            },
            {
              group_by: ['alertname', 'instance'],
              group_wait: '12s',
              group_interval: '12s',
              repeat_interval: '1h',
              receiver: 'slack-alert',
            },
          ]
        },
        receivers: [
          {
            name: 'slack-alert-contestants',
            slack_configs: [
              {
                send_resolved: true,
                api_url: 'https://hooks.slack.com/services/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',
                channel: '#alert-contestants',
                title_link: 'https://prometheus.ioi18.net',
                title: "{{ .CommonLabels.instance }} {{ .CommonLabels.ioi_contestant }} {{ .CommonLabels.ioi_desk }} ({{ .CommonLabels.job }})",
                text: "{{ range .Alerts }}*{{ .Status }}* {{ .Labels.ioi_contestant }} {{ .Labels.ioi_desk }} {{ .Annotations.summary }}\n{{ end }}",
              },
            ],
          },
          {
            name: 'slack-alert',
            slack_configs: [
              {
                send_resolved: true,
                api_url: 'https://hooks.slack.com/services/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',
                channel: '#alert',
                title_link: 'https://prometheus.ioi18.net',
                title: "{{ .CommonLabels.instance }} ({{ .CommonLabels.job }})",
                text: "{{ range .Alerts }}*{{ .Status }}* {{ .Annotations.summary }}\n{{ end }}",
              },
            ],
          },
        ],
        inhibit_rules: [
          #{
          #  source_match: {
          #    severity: 'critical',
          #  },
          #  target_match: {
          #    severity: 'warning',
          #  },
          #  equal: ['alertname', 'dev', 'instance'],
          #},
        ],
      },
    },
  },
)

include_cookbook 'prometheus-alertmanager'

directory '/mnt/vol/alertmanager' do
  owner 'prometheus'
  group 'prometheus'
  mode  '0755'
end

file "/etc/prometheus/alertmanager.yml" do
  content "#{node[:prometheus][:alertmanager].fetch(:config).to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, "service[prometheus-alertmanager.service]", :immediately
end

service "prometheus-alertmanager.service" do
  action [:enable, :start]
end
