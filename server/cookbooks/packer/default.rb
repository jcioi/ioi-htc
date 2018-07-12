package 'golang'
package 'make'

gopath = '/opt/go'

directory gopath do
  owner 'root'
  group 'root'
  mode '755'
end

file '/root/build_packer.sh' do
  owner 'root'
  group 'root'
  mode '755'
  content <<EOF
#!/bin/bash
set -eu
export GOPATH=#{gopath.shellescape}
export PATH=$GOPATH/bin:$PATH

go get -d github.com/hashicorp/packer
go get github.com/kardianos/govendor

make -C #{gopath.shellescape}/src/github.com/hashicorp/packer
EOF
end

execute '/root/build_packer.sh' do
  only_if "! test -x #{gopath.shellescape}/bin/packer"
end

link '/usr/local/bin/packer' do
  to "#{gopath}/bin/packer"
end
