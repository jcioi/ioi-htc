execute 'install intellij-idea-community' do
  script = <<EOF
mkdir -p /opt/idea
curl -fLsS https://download.jetbrains.com/idea/ideaIC-2018.1.6.tar.gz \
  | tar zx -C /opt/idea --strip=1
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/idea/bin/idea.sh'
end

link '/usr/local/bin/idea' do
  to '/opt/idea/bin/idea.sh'
end

include_cookbook 'xdg-desktop'

desktop_entry 'intellij-idea-community' do
  display_name 'IntelliJ IDEA Community'
  icon '/opt/idea/bin/idea.png'
  exec '/usr/local/bin/idea'
  categories %w(Development IDE Java)
end
