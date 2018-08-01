execute 'install intellij-idea-community' do
  script = <<EOF
tmp=$(mktemp --tmpdir "XXXXXXXXX.tar.gz")
mkdir -p /opt/idea
curl -fLsS -o "$tmp" https://download.jetbrains.com/idea/ideaIC-2018.1.6.tar.gz
echo "ca7c746a26bc58c6c87c34e33fbba6f767f2df9dca34eb688e3c07a126cdc393 $tmp" | sha256sum -c
tar zxf "$tmp" -C /opt/idea --strip=1
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
