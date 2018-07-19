execute 'install cppreference' do
  script = <<EOF
mkdir -p /opt/cppreference
curl -fLsS http://upload.cppreference.com/mwiki/images/1/1d/html_book_20180311.tar.xz \
  | tar Jx -C /opt/cppreference
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/cppreference/reference/en/index.html'
end
