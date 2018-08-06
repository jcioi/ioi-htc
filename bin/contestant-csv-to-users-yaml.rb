#!/usr/bin/env ruby
# Convert "Country,Position,Contestant No.,First Name, Last Name" CSV for improved_imoj.py loader YAML
require 'csv'
require 'yaml'
require 'securerandom'

def mkpassword
  SecureRandom.alphanumeric(20)
end

path = ARGV[0]
abort "Usage: #$0 path/to/contestants.csv" unless path

users = {}
teams = {}

File.open(path, 'r') do |io|
  csv = CSV.new(io, headers: true)
  csv.each do |row|
    next unless row['Position'] == 'Contestant'
    username = row.fetch('Contestant No.')
    teamcode = username.split(?-,2).first
    teams[teamcode] ||= {'code' => teamcode, 'name' => row.fetch('Country')}
    users[username] ||= {
      'username' => username,
      'first_name' => row.fetch('First Name'),
      'last_name' => row.fetch('Last Name'),
      'password' => mkpassword(),
      'team' => teamcode,
    }
  end
end

data = {
  'teams' => teams.values,
  'users' => users.values,
}

puts data.to_yaml
