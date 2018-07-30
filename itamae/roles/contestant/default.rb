node.reverse_merge!(
  contestant: {
    preview: false,
  },
  compilers: {
    install_doc: true,
  },
)

node[:contestant][:cms_uri] ||=
  if node[:contestant][:preview]
    'https://contest-practice.ioi18.net'
  else
    'https://contest.ioi18.net'
  end

group 'contestant' do
  gid 1000
end

include_cookbook 'isolate-recommendation'
include_cookbook 'compilers'
include_cookbook 'console-setup'

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

if node[:contestant][:preview]
  include_recipe './preview.rb'
end
