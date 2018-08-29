def preview?
  node.dig(:contestant, :preview)
end

node.reverse_merge!(
  contestant: {
    cms_uri: preview? ? 'https://contest-practice.ioi18.net' : 'https://contest.ioi18.net',
    ioiprint_uri: 'ioiprints://print.ioi18.net',
  },
  op_user: {
    homedir_mode: '700',
    authorized_keys: [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrfnnnnr9guAV2LgaWWHXoKZm7pfvCGiFx9nZe2O1CiL3N7BA7yckmFU6gIv/spNyRxKqkmnDRFgT1kWs84QkTqCjedOL1sEIzxoFsO/1yZoXyAnCHPZfJzQnQsxoyAQwJM/JYAK4u5YrlocjFfGKgLZ/tpRjV5VfX81lBrEvVj7OSfKj8Bvr0l3vX4dPH/Zs8CjcuwCR+r/iMKr/hFTzMin72ZXhZs1nvJFATVQZIjZHyULoGZy3f10PT8T/25TxQ82txqmS9v0HR7r2rma9o9DpKxCG5hDS/MEM9suIzgt/cedjqY5Wz/1bIjMmMkK7UBgHfsPJfdKZ3mZtAClb8Fq+XVOn07408jyU3/BOgQw7uDpGy82lRyfoaQztRa3vUTb6KTULuf20lwr+bPhOdNw0AvYZVLuS/QYinNpr4VhVV5LQvb/18pwQBt5QvMLkpgAp4RFNk0rEKJShARJY6HyS9tRRToDjnFVNCv63a7bvJpkHAo1CzgQmsSNWXW+WtmtGZtqXotViIePp/5+QmylKXQK9NL+OSfS0USNLvr4NF0v9OUGU9UP40z9yXwNVLoVzEeOZzdurMmphQ/tktMRgPfbkfA8opO7XImpJ2REoCD2YvYhdLsaKI7CaMij9CvDba4LzZHZl4V/o2QHtztL0+vqChwpWlcm5dj9KLEQ== ioi18m'
    ],
  },
  ioi_set_hostname: {
    template: 'contestant-m-%m',
  },
  compilers: {
    install_doc: true,
  },
  swap: {
    size: 4 * 2**30,
  },
  cups: {
    log_level: 'debug',
  },
)

unless preview?
  include_cookbook 'op-user'
  include_cookbook 'ioi-set-hostname'
  include_cookbook 'sshd'

  include_cookbook 'systemd-networkd'
  include_cookbook 'prometheus-node-exporter'
  include_cookbook 'prometheus-usb'
end

group 'contestant' do
  gid 1000
end

include_cookbook 'isolate-recommendation'
include_cookbook 'compilers'
include_cookbook 'console-setup'
include_cookbook 'disable-power-switches'
include_cookbook 'swap'

package 'ubuntu-desktop'
package 'fonts-noto'
package 'fonts-noto-cjk'

include_recipe './apps.rb'
include_recipe './desktop.rb'
include_recipe './autostart.rb'
include_recipe './skel.rb'
include_recipe './trust-launchers.rb'
include_recipe './disabled_apps.rb'
include_recipe './dconf.rb'
include_recipe './pam.rb'
include_recipe './limits.rb'
include_recipe './polkit.rb'
include_recipe './admin-commands.rb'

if preview?
  include_recipe './preview.rb'
else
  include_recipe './gdm.rb'
  include_recipe './modprobe.rb'
  include_recipe './printer.rb'
end
