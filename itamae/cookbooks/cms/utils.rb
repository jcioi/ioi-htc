remote_file '/usr/bin/ioi-cms-restart-units' do
  owner 'root'
  group 'root'
  mode  '0750'
end


remote_file '/usr/bin/ioi-cms-venv' do
  owner 'root'
  group 'root'
  mode  '0755'
end
