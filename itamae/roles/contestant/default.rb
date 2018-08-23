def preview?
  node.dig(:contestant, :preview)
end

node.reverse_merge!(
  contestant: {
    cms_uri: preview? ? 'https://contest-practice.ioi18.net' : 'https://contest.ioi18.net',
    ioiprint_uri: 'ioiprints://print-dev.ioi18.net',
  },
  op_user: {
    homedir_mode: '700',
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
  include_cookbook 'sshd'

  include_cookbook 'systemd-networkd'
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
