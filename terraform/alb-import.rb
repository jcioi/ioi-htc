require 'aws-sdk-elasticloadbalancingv2'

PUBLIC_SUBNET = %(["${data.aws_subnet_ids.public.ids}"])
PRIVATE_SUBNET = %(["${data.aws_subnet_ids.private.ids}"])

def tee(io, *args)
  $stdout.puts(*args)
  io.puts(*args)
end

elb = Aws::ElasticLoadBalancingV2::Client.new(region: 'ap-northeast-1')

name = ARGV[0]
unless name
  elb.describe_load_balancers().each do |page|
    page.load_balancers.each do |lb|
      puts "==== #{lb.load_balancer_name}"
      system('ruby', $0, lb.load_balancer_name) or raise
    end
  end
  exit
end
if File.exist?("elb_#{name}.tf") && !ENV['SKIP_IMPORT']
  puts "Skip #{name}" 
  exit
end

lb = elb.describe_load_balancers(
  names: [name]
).load_balancers[0]
lb_arn = lb.load_balancer_arn

listeners = elb.describe_listeners(load_balancer_arn: lb_arn).listeners
target_groups = elb.describe_target_groups(load_balancer_arn: lb_arn).target_groups

unless ENV['SKIP_IMPORT']
  File.open("elb_#{name}.tf", "w") do |io|
    tee io, %|resource "aws_lb" "#{name}" { }|
    listeners.each do |listener|
      tee io, %|resource "aws_lb_listener" "#{name}_#{listener.port}" { }|
    end
    target_groups.each do |target_group|
      if target_groups.size == 1
        tee io, %|resource "aws_lb_target_group" "#{name}" { }|
      else
        tee io, %|resource "aws_lb_target_group" "#{name}_#{target_group.target_group_name}" { }|
      end
    end
  end

  system("terraform", "import", "aws_lb.#{name}", lb.load_balancer_arn) or raise
  listeners.each do |listener|
    system("terraform", "import", "aws_lb_listener.#{name}_#{listener.port}", listener.listener_arn) or raise
  end
  target_groups.each do |target_group|
    if target_groups.size == 1
      system("terraform", "import", "aws_lb_target_group.#{name}", target_group.target_group_arn) or raise
    else
      system("terraform", "import", "aws_lb_target_group.#{name}_#{target_group.target_group_name}", target_group.target_group_arn) or raise
    end
  end
end

File.open("elb_#{name}.tf", "w") do |io|
  lb_attrs = elb.describe_load_balancer_attributes(load_balancer_arn: lb_arn).attributes
  tee io, %|resource "aws_lb" "#{name}" {|
  tee io, %|  name = "#{name}"|
  tee io, %|  internal = #{lb.scheme == 'internal' ? 'true' : 'false'}|
  tee io, ""
  tee io, %|  security_groups = [#{lb.security_groups.map{ |_| %("#{_}") }.join(?,)}]|
  if lb.scheme == 'internal'
    tee io, %|  subnets = #{PRIVATE_SUBNET}|
  else
    tee io, %|  subnets = #{PUBLIC_SUBNET}|
  end
  tee io, ""
  tee io, %|  idle_timeout = #{lb_attrs.find { |_| _.key == 'idle_timeout.timeout_seconds' }&.value || 60}|
  tee io, %|  enable_deletion_protection = #{lb_attrs.find { |_| _.key == 'deletion_protection.enabled' }&.value}|
  if lb_attrs.find{ |_| _.key == 'access_logs.s3.enabled' }&.value == 'true'
    tee io, ""
    tee io, %|  access_logs {|
    tee io, %|    bucket = "#{lb_attrs.find{ |_| _.key == 'access_logs.s3.bucket' }&.value}"|
    tee io, %|    prefix = "#{lb_attrs.find{ |_| _.key == 'access_logs.s3.prefix' }&.value}"|
    tee io, %|    enabled = true|
    tee io, %|  }|
  end
  tee io, %|}|

  listeners.each do |listener|
    tee io, %|resource "aws_lb_listener" "#{name}_#{listener.port}" {|
    tee io, %|  load_balancer_arn = "${aws_lb.#{name}.arn}"|
    tee io, %|  port = #{listener.port}|
    tee io, %|  protocol = "#{listener.protocol}"|
    if listener.protocol == 'HTTPS'
      tee io, %|  certificate_arn = "#{(listener.certificates.find(&:is_default) || listener.certificates.first).certificate_arn}"|
      tee io, %|  ssl_policy = "#{listener.ssl_policy}"|
    end
    tee io, ""
    tee io, %|  default_action {|
    if target_groups.size == 1
      tee io, %|    target_group_arn = "${aws_lb_target_group.#{name}.arn}"|
    else
      tee io, %|    target_group_arn = "#{listener.default_actions.first.target_group_arn}" # "${aws_lb_target_group.#{name}.arn}"|
    end
    tee io, %|    type = "#{listener.default_actions.first.type}"|
    tee io, %|  }|
    tee io, %|}|
  end

  target_groups.each do |tg|
    attrs = elb.describe_target_group_attributes(target_group_arn: tg.target_group_arn).attributes
    if target_groups.size == 1
      tee io, %|resource "aws_lb_target_group" "#{name}" {|
    else
      tee io, %|resource "aws_lb_target_group" "#{name}_#{tg.target_group_name}" {|
    end
    tee io, %|  name = "#{tg.target_group_name}"|
    tee io, %|  port = #{tg.port}|
    tee io, %|  protocol = "#{tg.protocol}"|
    tee io, %|  vpc_id = "#{tg.vpc_id}"|
    tee io, %|  target_type = "#{tg.target_type}"|
    tee io, %|  proxy_protocol_v2 = true| if attrs.find{ |_| _.key == 'proxy_protocol_v2.enabled' } == 'true'
    tee io, ""
    attrs.find{ |_| _.key == 'deregistration_delay.timeout_seconds' }.tap do |_|
      tee(io, %|  deregistration_delay = #{_.value}|) if _
    end
    attrs.find{ |_| _.key == 'slow_start.duration_seconds' }.tap do |_|
      tee(io, %|  slow_start = #{_.value}|) if _
    end
    tee io, ""
    tee io, %|  health_check {|
    tee io, %|    protocol = "#{tg.health_check_protocol}"| if tg.health_check_protocol != 'HTTP'
    tee io, %|    port = #{tg.health_check_port}| if tg.health_check_port != 'traffic-port'
    tee io, %|    path = "#{tg.health_check_path}"| if tg.protocol != 'TCP'
    tee io, %|    interval = #{tg.health_check_interval_seconds}|
    tee io, %|    healthy_threshold = #{tg.healthy_threshold_count}|
    tee io, %|    unhealthy_threshold = #{tg.unhealthy_threshold_count}|
    tee io, %|    matcher = "#{tg.matcher.http_code}"| if tg.protocol != 'TCP'
    tee io, %|  }|
    if attrs.find{ |_| _.key == 'stickiness.enabled' }&.value == 'true'
      tee io, ""
      tee io, %|  stickiness {|
      tee io, %|    type = "#{attrs.find{ |_| _.key == 'stickiness.type' }&.value}"|
      tee io, %|    cookie_duration = #{attrs.find{ |_| _.key == 'stickiness.lb_cookie.duration_seconds' }&.value}|
      tee io, %|    enabled = true|
      tee io, %|  }|
    end
    tee io, %|}|
  end

end
