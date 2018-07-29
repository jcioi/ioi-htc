%w[
  /etc/dconf
  /etc/dconf/profile
  /etc/dconf/db
  /etc/dconf/db/local.d
  /etc/dconf/db/local.d/locks
].each do |_|
  directory _ do
    owner 'root'
    group 'root'
    mode '755'
  end
end

execute 'dconf update' do
  action :nothing
end

file '/etc/dconf/profile/user' do
  owner 'root'
  group 'root'
  mode '644'
  content <<EOF
user-db:user
system-db:local
EOF
end

define :dconf_defaults, priority: '10', values: {}, lock: false do
  file "/etc/dconf/db/local.d/#{params[:priority]}-#{params[:name]}" do
    sections = params[:values].each.with_object({}) do |kv, h|
      path, value = *kv
      fail unless path.start_with?(?/)
      path = path.split(?/)
      (h[path[1...-1].join(?/)] ||= {})[path[-1]] = value
    end

    content = sections.map do |path, kv|
      "[#{path}]\n" + kv.map do |k, v|
        v = case v
            when String
              %{'#{v}'}
            when Symbol, Integer, true, false
              v.to_s
            else
              fail
            end
        "#{k}=#{v}\n"
      end.join + "\n"
    end.join

    owner 'root'
    group 'root'
    mode '644'
    content content
    notifies :run, 'execute[dconf update]'
  end

  if params[:lock]
    file "/etc/dconf/db/local.d/locks/#{params[:name]}" do
      content = params[:values].map do |path, _|
        "#{path}\n"
      end.join

      owner 'root'
      group 'root'
      mode '644'
      content content
      notifies :run, 'execute[dconf update]'
    end
  end
end
