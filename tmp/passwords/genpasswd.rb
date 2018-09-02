#!/usr/bin/env ruby
require 'securerandom'

$<.each_line(chomp: true) do |l|
  user, passwd = l.split(?:)
  puts [user, passwd.crypt("$6$#{SecureRandom.base64(12).tr(?+, ?.)}")].join(?:)
end
