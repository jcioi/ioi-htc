# Give pam_mkhomedir a higher priority than pam_systemd
# so that systemd user units can access the home directory.
remote_file '/usr/share/pam-configs/mkhomedir' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[pam-auth-update --package]'
end

execute 'pam-auth-update --enable mkhomedir' do
  not_if %{echo 'get libpam-runtime/profiles' | debconf-communicate | grep -q mkhomedir}
end

execute 'pam-auth-update --package' do
  action :nothing
end
