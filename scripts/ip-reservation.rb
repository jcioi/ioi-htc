#!/usr/bin/env ruby
require 'ipaddr'

ipaddrs = %w[10.18.10.0 10.18.62.0].map(&IPAddr.method(:new))
$stdin.each_line(chomp: true) do |mac|
  mac = mac.downcase.gsub(?:, '').each_char.each_slice(2).map(&:join).join(?:)
  puts [mac, *ipaddrs].join(?,)
  ipaddrs.map!(&:succ)
end
