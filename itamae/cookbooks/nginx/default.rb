node.reverse_merge!(
  nginx: {
    user: 'www-data',
    worker_processes: 'auto',
    worker_connections: 8192,
    worker_rlimit_nofile: 17824,
    keepalive_timeout: 65,
    client_max_body_size: '4G',
    client_body_buffer_size: '128k',
    proxy_buffers: '100 64k',
    proxy_buffer_size: '8k',
    large_client_header_buffers: '4 8k',
    proxy_read_timeout: '60s',
    proxy_connect_timeout: '5s',
    server_names_hash_bucket_size: 128,
    proxy_headers_hash_bucket_size: 64,
    log_format: %w[
      status:$status
      time:$time_iso8601
      reqtime:$request_time
      method:$request_method
      uri:$request_uri
      protocol:$server_protocol
      ua:$http_user_agent
      forwardedfor:$http_x_forwarded_for
      host:$remote_addr
      referer:$http_referer
      server_name:$server_name
      vhost:$host
      size:$body_bytes_sent
      reqsize:$request_length
      runtime:$upstream_http_x_runtime
      apptime:$upstream_response_time
     ].join('\t'),
    default_conf: true,
  }
)

include_cookbook 'apt-source-nginx'

package "nginx-full" do
end

directory '/var/log/nginx' do
  owner 'www-data'
  group 'www-data'
  mode  '0755'
end

template '/etc/nginx/nginx.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

directory '/etc/nginx/utils' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/nginx/utils/force_https.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[nginx try-reload]'
end

remote_file '/etc/nginx/utils/httpd_alived.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[nginx try-reload]'
end

template '/etc/nginx/utils/tls_modern.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[nginx try-reload]'
end

directory '/etc/nginx/conf.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

if node.dig(:nginx, :default_conf)
  template '/etc/nginx/conf.d/default.conf' do
    owner 'root'
    group 'root'
    mode '644'
    notifies :run, 'execute[nginx try-reload]'
  end
else
  file '/etc/nginx/conf.d/default.conf' do
    action :delete
  end
end

directory '/etc/nginx/public' do
  owner 'root'
  group 'root'
  mode  '0755'
end

execute 'nginx try-reload' do
  command 'nginx -t && systemctl try-reload-or-restart nginx.service'
  action :nothing
end
