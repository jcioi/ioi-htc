DEFAULT_AUTHORIZED_KEYS = [
  # ioi18
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+El9TFI2B29UcJwL3/vhmca7RTsT3oClyDQ5WzoYQWhXqbvCzvD5jlzCYxYL3wIN3bmsVW/ZiWRb4pj9AqUQX44/KUlnsqqf4pj2WdkZmgNjaSlT1jtbJhUO8sT6C3mN+cdIzTiy05AB+HvrG46Yq0fUzk2q9CQ/dACd8QizjoGC3aT08n1sG04L86/hEU6dvQO5lwX3GefzUSVzyce4GcqTwEoW7lHYdJkiI8Du0vjbjigO5AjfTjhCdI7Y78FOZTSW/GoWsXzIaKgog58OPFY045aZurP+Kc3pWz76USCUBNSr4w+tD8IpUzBgyD2GN/3UVjv9u9sHLtglZdNHq5KPHjGAeNgwnk90BOFKhuLrrZ5rdnImXq7ULtmgXSTuURM1KQ7WIOxLAkk9aZn1D1qkBUxKR6CqcJ2RWt6T29fIA2Vm6jW+CBvKYWw87hCw6eRLMn6Chkbz9Y4m8QeSZnzV0TfyDmAgD8UfbfAP/TVVve0Df8YbW6IKYEfgf/eEAg2VcxF9k4QguksIXgWaXJeylVVI5FHf0B2zB2gMra/FASNUG9/HCqMVos8U8lq9DQXMh4Hs2bbQoqF3BpH8QdGeZnJzUA+iu3JKuo1U6M/+UdRA/cloFVpFOROTqv92oaLLx6a/6gOSzXg41Zwtz5rsZhRPqqnDx2zXY+r2FnQ== ioi18b",

  # sorah
  *"
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADLFfXAbYvLbd3gTH08FfYEADFWVaa2xoHC4pzMNy+MoPbf9qPWTLGYlkXPL7QxgZH6dRk458rkfwEIySxajdIr0AEGcrvVTezzhYNvZReISWMBlO68cDprusADqLqoLus2booss4LIKmm6BI4vuuXtOOVhAdltj0gf/CVlpNuZ99szFw== americano2016ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACG1cKNR8SS4Dkm2wcia74RRmy9d7h62114MQd0H9zb1+1LxVa55Qqd8O232BH1i/fF/1o+eE3L5U7RCR8KUCuAXgFrF429BETaiiBnSErv5yrHJS5RTTjEhA1d9Ygk0o3Und6+90waBXAk2oPVP+OBNtYq1CraZQsXuqvlUtMrBnSTsQ== sorah-mulberry-ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF6LlpYSW3SrzjQcZYifI0JYJlUpj5myp/20h7/HxL8aImwU9pBSPch9NH2QL8RB/G5MlaZ1P52Kg4bVueJCwVoPABIEDx/u1ilSS+03UJW6Yfh3a7VT/iuudlFyUPY2x9M4Cf/JgXCaCV7Yb/f4JaCjulGXKbzzHx58EIcqNxbp64Jug== sorah-w1-my-ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHoLUkgSzQfIXMx7nS9TzgFubVwYBiaWYPh2Ges30IMytU8oQyrQ4V/mPjvWHrij9pz0Uz+tbhR1+Tza85LzyFiCwDrZDQNqLGB7b/bwhy9cGQPVGUdiObJ4f2MEPYzyueEtmCQuh1NiPl/p8HSIyEBOmc19duWfKyvDRvayg8hJAs4mg== sorah-wD-my-ecdsa
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnY8uGqMVviIttNHiz1M5MV5jL3GSt3nGWPxEErmEbaORQabn1UvBennzi87E4ZXa6wT9ZcfmvcrcckW6xiopU0A8CJSQAvKtpOB4eSFJkblELrmUpmxuDo5pHLpunpHHay2or8yPaLnwSfBnuyA7Lq2Cj1pw0LKq88Lda76ihWPWb7DfBVzedVYPKKunIk/4Wwj120ILOcoYI0r0XWiaxx9d3IvNvXroR7qqiKKZMacBpUWCwT3iX6GB0jhSRIJ1Do9qDyp/Sx4wyj4SxXasni5pqg/8ARwCkiMrbkAaedRRvP4umxuhBRc4VzqeWTvj5dPlkguwt1avbg3g/IDuO7/iJSEASN2H7qJEhH5rL5Aq1HCkOHGdlibdsFLNiCoOGKMNRO4mPsAkyf4i/kURP+a50+lRVlQSGGzFR5FFFcR0P83E+BkS/UkxC9MVGkvidLSmto/UkGqCfdLP6RJQMH6W54KMQ1epjWiLvW9FkspRha73lfxh7pC+jACRmL0E= sorah-w2-my
  ".lines.map(&:strip).reject(&:empty?),

  #hanazuki
  "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABQq66J8rYkw0OwRmg/9yU1zrFUUv6K6ljA1fQ/xYmf2hrsHzRXnPg3DMT4YRUZx79J8zPuPZJw2+QT/NfXfR84hgAhSx+cOXqhgD/fGB7m0JxqoUPnwU9jFmemfYV4QLKw3glBjGQejGpY/IrKePodGtpntwb64km2E6H/E9RHK+Vp6A==",
  "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF0DegCLS0WpvTmdIZphFGx8gSX+wFq//STOi36Php9NviUCoPgfECJRI+iqT/fNcH1sIV3IgT9En3fb6LHDAgRlQH9L74ezCF//PMd6WmO+WmiqcomLBenV0BPFBQyDnAeCp35lVgH4jLXyQ1JMdfwErW0GLz0QLgC8HYe2/ENMTCyLA==",
]

node.reverse_merge!(
  op_user: {
    name: node.fetch(:op_user_name),
    password: node[:op_user_password],
    authorized_keys: [],
    include_default_authorized_keys: true,
    homedir_mode: '0755',
  },
)

username = node[:op_user].fetch(:name)
password = node[:op_user].fetch(:password)

group username do
  gid 10000
end

user username do
  uid 10000
  gid 10000
  password password if password
  home "/home/#{username}"
  shell '/bin/bash'
  create_home true
end

directory "/home/#{username}" do
  owner username
  group username
  mode node.dig(:op_user, :homedir_mode)
end

directory "/home/#{username}/.ssh" do
  owner username
  group username
  mode "0700"
end

file "/home/#{username}/.ssh/authorized_keys" do
  authorized_keys = node[:op_user][:authorized_keys]
  if node[:op_user][:include_default_authorized_keys]
    authorized_keys.concat DEFAULT_AUTHORIZED_KEYS
  end

  content authorized_keys.join(?\n) + ?\n
  owner username
  group username
  mode "600"
end

file '/etc/sudoers.d/opuser' do
  content "#{username} ALL=(ALL) NOPASSWD:ALL\n"
  owner 'root'
  group 'root'
  mode '440'
end
