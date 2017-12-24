node[:basedir] = File.expand_path('..', __FILE__)
node[:secrets] = MitamaeSecrets::Store.new(File.join(node[:basedir],'secrets'))

node[:op_user_name] = 'ioi'
node[:orgname] = 'ioi18'
node[:site_domain] = 'ioi18.net'
node[:contest_id] = 1
# node[:site_cidr] = '10.0.0.0/16'
# node[:site_cidr6] = ''

execute "systemctl daemon-reload" do
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
      only_if "! apt-key list | grep -q '/#{name} ' || apt-key list | grep -Eq '/#{name}\s.+expired'"
    end
  else
    execute "apt-key #{name}" do
      command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys #{name}"
      only_if "! apt-key list | grep -q '/#{name} ' || apt-key list | grep -Eq '/#{name}\s.+expired'"
    end
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
