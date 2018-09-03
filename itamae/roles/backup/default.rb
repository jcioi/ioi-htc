node.reverse_merge!(
  ioi_contestant_backup: {
    config: {
      ssh: {
        user: 'ioi',
        key: '/etc/ioi-contestant-backup/id_rsa',
      },
      s3: {
        bucket: 'ioi18-backup',
        prefix: 'prd',
      },
      machines: ['10.18.60.13'] + node[:onsite_contestant_machines],
      concurrency: 8,
    },
  },
)

include_role 'base'
include_cookbook 'awscli'

remote_file '/etc/systemd/system/ioi-contestant-backup.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/usr/bin/ioi-contestant-backup' do
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[ioi-contestant-backup.service]'
end

directory '/etc/ioi-contestant-backup' do
  owner 'root'
  group 'root'
  mode '0700'
end

file '/etc/ioi-contestant-backup/config.json' do
  content JSON.dump(node['ioi_contestant_backup']['config'])
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[ioi-contestant-backup.service]'
end

file '/etc/ioi-contestant-backup/id_rsa' do
  content node[:secrets].fetch(:ioi_machine_ssh_private_key)
  owner 'root'
  group 'root'
  mode '0600'
  notifies :restart, 'service[ioi-contestant-backup.service]'
end

directory '/usr/share/ioi-contestant-backup' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/usr/share/ioi-contestant-backup/rsync-helper' do
  owner 'root'
  group 'root'
  mode '0755'
end

service 'ioi-contestant-backup.service' do
  action [:enable, :start]
end
