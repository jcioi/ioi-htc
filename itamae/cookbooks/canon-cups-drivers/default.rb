dpkg_foreign_architecture 'i386'

remote_file '/etc/apt/trusted.gpg.d/exapico.gpg' do
  owner 'root'
  group 'root'
  mode '644'
end

file '/etc/apt/sources.list.d/ioi18.list' do
  action :create
  owner 'root'
  group 'root'
  mode '644'
  content "deb http://apt.exapi.co/ioi18 bionic main\n"
  notifies :run, 'execute[apt-get update]', :immediately
end

%w[
  libxml2:i386
  libstdc++6:i386
  cndrvcups-lipslx
].each do |_|
  package _ do
    action :install
  end
end
