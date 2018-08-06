file "/home/#{node.fetch(:op_user_name)}/.ssh/id_ecdsa" do
  content "#{node[:secrets].fetch(:id_ecdsa_ioi18bot)}\n"
  owner 'ioi'
  group 'ioi'
  mode  '0600'
end

remote_file "/home/#{node.fetch(:op_user_name)}/.ssh/id_ecdsa.pub" do
  owner 'ioi'
  group 'ioi'
  mode  '0644'
end
