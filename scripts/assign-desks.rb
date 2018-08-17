#!/usr/bin/env ruby
require 'yaml'
require 'csv'

desks = %w[
  G H 9 5 6
  E F 9 5 5
  C D 8 5 6
  A B 8 5 5
].each_slice(5).map do |a, b, h, aw, bw|
  (1..h.to_i).flat_map do |y|
    (1..aw.to_i).map { |x| "#{a}-#{y}#{x}" } +
      (1..bw.to_i).map {|x| "#{b}-#{y}#{x}" }
  end
end

%w[D-16 D-26 D-86 H-16 H-26 H-76 H-86 H-96].each do |desk|
  desks.each {|row| row.delete(desk) }
end

desk_count = desks.map(&:size).sum
fail "Incorrect number of desks" unless desk_count == 349


contestants = YAML.load_file('IOI2018_Contestants-20180802.yml')
users = contestants['users'].each {|user| user.delete('password') }.map(&:freeze)

spare_desks = %w[A-11 A-21 E-91 D-36 D-76 H-36]
fail "Incorrect number of spare desks" unless desk_count == users.size + spare_desks.size

users_by_team = users.group_by {|u| u['team'] }.sort_by {|t| -t[1].size }

class Dame < StandardError; end

begin
  assignment = {}
  desks.flatten.sort.each {|desk| assignment[desk] = nil }

  available_desks = desks.map {|block| block - spare_desks }

  users_by_team.each do |_, users|
    i = 0
    n = available_desks.size
    users.shuffle.each do |u|
      i += 1 while available_desks[i%n].empty?
      d = available_desks[i%n].sample
      available_desks[i%n].delete(d)
      assignment[d] = u
      i += 1
    end
  end

  fail "Not all users are assigned" unless assignment.values.reject(&:nil?).uniq.size == users.size

  def desks.neibours(desk)
    a,y = *desk.scan(/\A(.)-(.).\z/)[0]
    c_b = (a.ord-?A.ord) % 2 == 0 ? [a, (a.ord+1).chr] : [(a.ord-1).chr, a]
    c_y = [y.to_i-1, y, y.to_i+1].map(&:to_s)

    prefixes = c_b.product(c_y).map {|*p| p.join(?-) }
    self.flatten.select {|d| prefixes.any? {|p| d.start_with?(p) } && d != desk }
  end

  desks.flatten.each do |desk|
    neibours = desks.neibours(desk)
    user = assignment[desk]
    next unless user

    neibours.each do |nei|
      nei_user = assignment[nei]
      next unless nei_user

      raise Dame if user['team'] == nei_user['team']
    end
  end

  csv = CSV.generate(headers: %w[desk username], write_headers: true) do |csv|
    assignment.each do |desk, user|
      csv << [desk, user&.[]('username')]
    end
  end
  IO.write('desk_assignment.csv', csv)
rescue Dame
  retry
end
