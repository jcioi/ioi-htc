user 'cmsuser' do
  uid 900
  shell '/bin/false'
  system_user true
end

if node.dig(:op_user, :name)
  opuser = node.dig(:op_user, :name)
  execute "usermod -a -G cmsuser #{opuser}" do
    not_if "id -zG #{opuser} | grep -z -q -x 900"
  end
end


