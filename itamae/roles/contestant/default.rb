node.reverse_merge!(
  contestant: {
    preview: false,
  },
  compilers: {
    install_doc: true,
  },
)

if node[:contestant][:preview]
  include_recipe './preview.rb'
end

package 'ubuntu-desktop'

include_cookbook 'compilers'
