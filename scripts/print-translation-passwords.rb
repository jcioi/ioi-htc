#!/usr/bin/env ruby

require 'csv'
require 'json'
require 'net/http'
require 'uri'

IOIPRINT = URI(ARGV.include?('--dev') ? 'https://print-dev.ioi18.net/password' : 'https://print.ioi18.net/password')


countries = CSV.open('./countries.csv', headers: true).read
languages = CSV.open('./languages.csv', headers: true).read
users = CSV.open('./users.csv', headers: true).read

print_users = users.map do |user|
  fail 'country not found' unless country = countries.find {|c| c['code'] == user['country'] }
  fail 'language not found' unless language = languages.find {|l| l['code'] == user['language'] }

  {
    name: "#{country['name']} (#{language['name']})",
    login: user['username'],
    password: user['raw_password'],
  }
end

payload = {title: "Password for Translation", users: print_users}

http = Net::HTTP.new(IOIPRINT.host, IOIPRINT.port)
http.use_ssl = IOIPRINT.is_a? URI::HTTPS
http.post2(IOIPRINT.path, JSON.dump(payload),
           'Content-Type' => 'application/json') do |resp|
  puts resp.body
end
