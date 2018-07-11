node.reverse_merge!(
  contestant: {
    preview: false,
  }
)

if node[:contestant][:preview]
  include_recipe './preview.rb'
end

package 'ubuntu-desktop'
