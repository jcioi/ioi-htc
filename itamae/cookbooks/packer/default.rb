node.reverse_merge!(
  packer: {
    release: '1.2.5',
  },
)

release = node[:packer].fetch(:release)
node[:packer][:zip_url] = "https://releases.hashicorp.com/packer/#{release}/packer_#{release}_linux_amd64.zip"

%W[
  /opt/packer-#{release}
  /opt/packer-#{release}/bin
].each do |_|
  directory _ do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

execute 'download packer' do
  script = <<EOF
zip=/opt/packer-#{release}.zip
curl -fLsS -o "$zip" #{node[:packer][:zip_url].shellescape}
unzip -d /opt/packer-#{release}/bin "$zip"
EOF

  command "bash -euxc #{script.shellescape}"
  not_if "test -e /opt/packer-#{release}/bin/packer"
end

link '/usr/local/bin/packer' do
  to "/opt/packer-#{release}/bin/packer"
end
