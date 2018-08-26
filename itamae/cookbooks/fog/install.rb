repo = node[:fog][:repo]
branch = node[:fog][:branch]

execute 'clone fog installer' do
  command "git clone --depth=1 --single-branch --branch #{branch.shellescape} #{repo.shellescape} /opt/fogproject"
  not_if 'test -d /opt/fogproject/.git'
end

execute 'update fog installer' do
  command 'cd /opt/fogproject && git checkout FETCH_HEAD'
  not_if <<EOF
cd /opt/fogproject && git fetch origin #{branch.shellescape} && \
  test "$(git rev-parse HEAD)" = "$(git rev-parse FETCH_HEAD)"
EOF
end

directory '/opt/fog' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/opt/fog/.fogsettings' do
  owner 'root'
  group 'root'
  mode '0600'
end

execute 'installfog.sh' do
  command 'cd /opt/fogproject/bin && ./installfog.sh --autoaccept && git rev-parse HEAD > /opt/fog/.revision'
  only_if %{test ! -e /opt/fog/.revision || test "$(cat /opt/fog/.revision)" != "$(cd /opt/fogproject; git rev-parse HEAD)"}
end
