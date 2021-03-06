node[:basedir] = File.expand_path('..', __FILE__)
node[:secrets] = MitamaeSecrets::Store.new(File.join(node[:basedir],'secrets'))

node[:op_user_name] = 'ioi'
unless node[:hocho_ec2]
  node[:op_user_password] = node[:secrets].fetch(:ioi_password_crypt)
end

node[:orgname] = 'ioi18'
node[:site_domain] = 'ioi18.net'

node[:contest_ids] = {
  'dev' => 1,
  'practice' => 1,
  'prd' => 6, # day-2
}
node[:site_cidr] = '10.18.0.0/16'
# node[:site_cidr6] = ''

node[:cidr] = {
  adm: '0.18.40.0/21',
  life: '10.18.56.0/22',
  arena: '10.18.60.0/22',
  lab: '10.18.96.0/19',
}

if node.dig(:hocho_vpc, :cidr_block)
  node[:resolvers] = [IPAddr.new(node.dig(:hocho_vpc, :cidr_block)).to_s.sub(/\.0$/,'.2')]
else
  # dns-cache-001,dns-cache-002
  node[:resolvers] = %w(10.18.205.55 10.18.221.163)
end
node[:resolvers_global] = %w(10.18.205.55 10.18.221.163)

node[:desired_hostname] ||= node.dig(:hocho_ec2, :tags, :Name)

if node[:hocho_ec2]
  node[:ntp_servers] = %w(time1.google.com time2.google.com time3.google.com time4.google.com)
else
  node[:ntp_servers] = %w(ntp-001.apne1.aws.ioi18.net ntp-002.apne1.aws.ioi18.net)
end

if node[:hocho_ec2]
  if run_command('test -e /dev/disk/by-path', error: false).exit_status == 0
    package 'nvme-cli'
    extra_disk = run_command("for x in /dev/nvme*n1; do if nvme id-ctrl --raw-binary $x 2>/dev/null | cut -c3073-3104 | tr -s ' ' | grep -q sdf; then echo $x; fi ; done", error: true).stdout.strip
    node[:extra_disk] = extra_disk unless extra_disk.empty?
  else
    node[:extra_disk] =  '/dev/xvdf'
  end
end

include_recipe './machines'

execute "systemctl daemon-reload" do
  action :nothing
end
execute "systemctl reload apparmor.service" do
  action :nothing
end


execute "apt-get update" do
  action :nothing
end

execute 'update-initramfs' do
  command "update-initramfs -c -k all"
  action :nothing
end

define :apt_key, keyname: nil do
  name = params[:keyname] || params[:name]
  if node[:http_proxy]
    execute "apt-key #{name}" do
      command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-option http-proxy=#{node[:http_proxy]} --recv-keys #{name}"
      not_if "apt-key export #{name}|grep -q PGP"
    end
  else
    execute "apt-key #{name}" do
      command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys #{name}"
      not_if "apt-key export #{name}|grep -q PGP"
    end
  end
end

define :dpkg_foreign_architecture, arch: nil do
  name = params[:arch] || params[:name]
  execute "dpkg --add-architecture #{name}" do
    not_if "dpkg --print-foreign-architectures | grep -Fx #{name}"
    notifies :run, 'execute[apt-get update]'
  end
end

define :fstab, device: nil, mountpoint: nil, fstype: nil, options: nil, dump: 0, fsckorder: 0 do
  device = params[:device] || params[:name]
  mountpoint = params[:mountpoint]
  fstype = params[:fstype]
  mount_options = params[:options]
  dump = params[:dump]
  fsckorder = params[:fsckorder]

  new_fstab = "#{device} #{mountpoint} #{fstype} #{mount_options} #{dump} #{fsckorder}"

  file '/etc/fstab' do
    action :edit
    block do |content|
      if content =~ /^#{device}\s/
        content.gsub!(/^#{device}\s.*$/, new_fstab)
      else
        content.chomp!
        content << "\n#{new_fstab}\n"
      end
    end
  end
end

define :mount, mountpoint: nil do
  mountpoint = params[:mountpoint] || params[:name]

  execute "mount #{mountpoint}" do
    command "mount #{mountpoint}"
    not_if "mount | egrep -q '\\s#{mountpoint}\\s'"
  end
end

define :statoverride, path: nil, owner: 'root', group: 'root', mode: '0644' do
  file = params[:path] || params[:name]
  owner = params[:owner]
  group = params[:group]
  mode = params[:mode]

  execute "dpkg-statoverride #{file}" do
    command %{dpkg-statoverride --update --force --add #{owner.shellescape} #{group.shellescape} #{mode.shellescape} #{file.shellescape}}
    only_if %{test "$(dpkg-statoverride --list #{file.shellescape} | cut -d' ' -f1-3)" != #{"#{owner} #{group} #{mode}".shellescape}}
  end
end

MItamae::RecipeContext.class_eval do
  ROLES_DIR = File.expand_path("../roles", __FILE__)
  def include_role(name)
    recipe_file = File.join(ROLES_DIR, name, "default.rb")
    include_recipe(recipe_file.to_s)
  end

  COOKBOOKS_DIR = File.expand_path("../cookbooks", __FILE__)
  def include_cookbook(name)
    names = name.split("::")
    names << "default" if names.length == 1
    names[-1] += ".rb"

    candidates = [
      File.join(COOKBOOKS_DIR, *names),
    ]
    candidates.each do |candidate|
      if File.exist?(candidate)
        include_recipe(candidate)
        return
      end
    end
    raise "Cookbook #{name} couldn't found"
  end
end
