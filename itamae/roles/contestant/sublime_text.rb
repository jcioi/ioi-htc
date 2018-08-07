execute 'install sublime-text' do
  script = <<EOF
tmp=$(mktemp --tmpdir "XXXXXXXXX.tar.bz2")
mkdir -p /opt/sublime_text
curl -fLsS -o "$tmp" https://download.sublimetext.com/sublime_text_3_build_3176_x64.tar.bz2
echo "74f17c1aec4ddec9d4d4c39f5aec0414a4755d407a05efa571e8892e0b9cf732 $tmp" | sha256sum -c
tar xf "$tmp" -C /opt/sublime_text --strip=1
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/sublime_text/sublime_text'
end

link '/usr/local/bin/sublime_text' do
  to '/opt/sublime_text/sublime_text'
end

include_cookbook 'xdg-desktop'

desktop_entry 'sublime_text' do
  display_name 'Sublime Text'
  comment 'Sublime Text'
  icon '/opt/sublime_text/Icon/256x256/sublime-text.png'
  exec '/usr/local/bin/sublime_text'
  categories %w(TextEditor Development)
end
