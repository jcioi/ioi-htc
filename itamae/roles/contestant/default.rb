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

include_cookbook 'compilers'

package 'ubuntu-desktop'
package 'fonts-noto'
package 'fonts-noto-cjk'

include_recipe './apps.rb'
include_recipe './desktop.rb'
include_recipe './skel.rb'
include_recipe './trust-launchers.rb'

if node[:contestant][:preview]
  include_recipe './preview.rb'
end
