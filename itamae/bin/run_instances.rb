#!/usr/bin/env ruby
require 'optparse'
require 'open-uri'
require 'tempfile'
require 'aws-sdk-s3'
require 'aws-sdk-ec2'
require 'json'
require 'yaml'
require 'logger'

Aws.config[:logger] = Logger.new($stderr)

edit = nil

options = {
  names: [],
  instance_type: 't2.micro',
  vpc: "vpc-03eed691a6a5a03b2",
  subnets: [],
  security_groups: %w(default),
  image_id: 'ami-e875a197',
  key_name: 'id_rsa.ioi18b',
  public_ip: nil,
  volumes: { '/dev/sda1' => { device_name: '/dev/sda1', ebs: {volume_size: 15, volume_type: 'gp2'} } },
  role: nil,
  ebs_optimized: false,
  wait: false,
}

parser = OptionParser.new do |_|
  _.on('--no-edit') { edit = false }
  _.on('-e', '--edit') { edit = true }

  _.on('-w', '--wait') { options[:wait] = true }

  _.on('-n NAME', '--name NAME') { |n| options[:names] << n }

  _.on('-t TYPE', '--type TYPE') { |t| options[:instance_type] = t }

  _.on('-v VPC', '--vpc VPC') { |v| options[:vpc] = v }
  _.on('-s SUBNET', '--subnet SUBNET') { |s| options[:subnets] << s }

  _.on('--no-default-sg') { security_groups.delete('default') }
  _.on('-g SECURITYGROUP', '--sg SECURITYGROUP') { |g| options[:security_groups] << g }

  _.on('-i IMAGE', '--image') { |i| options[:image_id] = i }

  _.on('-k KEY', '--key KEY') { |k| options[:key_name] = k }

  _.on('-l LIKE', '--like LIKE') { |k| options[:like] = k }

  _.on('-p', '--public-ip') { options[:public_ip ] = true }
  _.on('-P', '--no-public-ip') { options[:public_ip] = false }

  _.on('--ebs VOL', '-V VOL') { |v|
    param = v.split(?,).map { |kv| k,v=kv.split(?=,2); [k.to_sym, v] }.to_h
    spec = {
      device_name: param[:device] || param[:dev],
      ebs: {
        volume_type: param[:type] || 'gp2',
        volume_size: (param[:size] || 15).to_i,
      }
    }
    spec[:ebs][:iops] = param[:iops] if param.key?(:iops)
    spec[:ebs][:snapshot_id] = param[:snapshot] if param.key?(:iops)
    options[:volumes][spec[:device_name]] = spec
  }

  _.on('-r ROLE', '--role ROLE') { |r| options[:role]= r }

  _.on('--ebs-optimized') { options[:ebs_optimized] = true }
end

parser.parse(ARGV)

region = 'ap-northeast-1'
@ec2 = Aws::EC2::Resource.new(region: region)


#######
def fetch_subnets(vpc)
  @ec2.subnets(filters: [name: 'vpc-id', values: [vpc]]).map do |subnet|
    name = subnet.tags.find{ |_| _.key == 'Name' }&.value || subnet.subnet_id
    [name, subnet.subnet_id]
  end.sort_by(&:first).to_h
end
if options[:vpc]
  subnets = fetch_subnets(options[:vpc])
else
  subnets = {}
end

if edit.nil?
  edit = options[:names].empty? || options[:image_id].nil? || options[:vpc].nil? || options[:subnets].empty?
end

if options[:like]
  like_spec = options.delete(:like)
  like = case like_spec
  when /\Ai-/
    @ec2.instances(instance_ids: [like_spec]).first
  else
    @ec2.instances(filters: [{name: 'tag:Name', values: [like_spec]}]).first
  end
  raise "No instance found for #{like_spec}" unless like

  options[:instance_type] = like.instance_type
  options[:vpc] = like.vpc_id
  options[:subnets] = [like.subnet_id]
  options[:security_groups] = like.security_groups.map(&:group_name)
  options[:key] = like.key_name
  options[:public_ip] = !!like.public_ip_address
  options[:role] = like.iam_instance_profile&.arn&.split(?/)&.last
  options[:ebs_optimized] = like.ebs_optimized
  options[:tags] = like.tags.map{ |_| _.key == 'Name' ? nil : [_.key, _.value] }.compact.to_h
end

if edit
  Tempfile.new(['runinstance', '.yml']).tap do |f|
    f.puts options.to_yaml
    f.puts
    f.puts "## Subnets:"
    subnets.each do |name, id|
      f.puts "#  - #{name} # #{id}"
    end
    f.flush
    system(ENV.fetch('EDITOR', 'vim'), f.path)
    f.rewind
    options = YAML.load(f.read)
  end
end

vpc = @ec2.vpc(options[:vpc])
subnets = fetch_subnets(options[:vpc])

image = case options[:image_id]
when /\Aami-/
  @ec2.image(options[:image_id])
when /\Aubuntu-(.+)/
  image_id = open("https://cloud-images.ubuntu.com/query/#{$1}/server/released.current.txt",&:read).each_line.lazy.map { |_|
    name,_,_,release,type,arch,iregion,image_id,_,_,vt = _.chomp.split(?\t)
    {name: name, release: release, type: type, arch: arch, region: iregion, image_id: image_id, virtualization_type: vt}
  }.find { |release|
    release[:name] == $1 && release[:region] == region && release[:virtualization_type] == 'hvm' && release[:type] == 'ebs-ssd'
  }[:image_id]
  @ec2.image(image_id)
#when /\A{/
#  JSON.parse(options[:image_id])
end

block_device_mappings = options[:volumes].values
security_groups = vpc.security_groups(filters: [name: 'group-name', values: options[:security_groups]]).map(&:group_id).uniq


instances = options[:names].flat_map.with_index do |name, index|
  subnet_name = options[:subnets][index % options[:subnets].size]
  subnet = subnets.fetch(subnet_name)

  run_instance_options = {
    min_count: 1,
    max_count: 1,
    image_id: image.image_id,
    key_name: options[:key_name],
    instance_type: options[:instance_type],
    block_device_mappings: block_device_mappings,
    disable_api_termination: options[:disable_api_termination],
    network_interfaces: [
      {
        device_index: 0,
        subnet_id: subnet,
        groups: security_groups,
        delete_on_termination: true,
        associate_public_ip_address: options[:public_ip],
      },
    ],
    iam_instance_profile: {
      name: options[:role],
    },
    ebs_optimized: options[:ebs_optimized],
  }

  if options[:public_ip].nil?
    run_instance_options[:network_interfaces].each do |nic|
      nic.delete :associate_public_ip_address
    end
  end

  tags = {'Name' => name}.merge(options[:tags] || {}).map do |k, v|
    {key: k.to_s, value: v.to_s}
  end

  Thread.new do
    @ec2.create_instances(run_instance_options).to_a.tap do |is|
      is.each do |instance|
        instance.create_tags(tags: tags)
      end
    end
  end
end.flat_map(&:value)

until instances.all? { |_| _.private_ip_address }
  instances.map! do |instance|
    instance.reload
  end
end

instances.each do |instance|
  pubip_info = if instance.public_dns_name
                 ": #{instance.public_dns_name} (#{instance.public_ip_address})"
               end
  warn "- #{instance.instance_id} (#{instance.vpc_id} / #{instance.subnet_id} / #{instance.placement.availability_zone})#{pubip_info}"
end

if options[:wait]
  instances.map do |instance|
    Thread.new do
      instance.wait_until(max_attempts:120, delay: 20) { |i| i.state.name == 'running' }
    end
  end.each(&:join)
end

######

