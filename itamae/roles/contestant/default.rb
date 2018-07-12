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

## Editors
package 'emacs'
package 'gedit'
package 'nano'
package 'vim'
package 'vim-gtk3'

## Interpreters
package 'python'
package 'python-doc'
package 'python3'
package 'python3-doc'
package 'ruby'
package 'ruby2.5-doc'

## Debuggers
package 'ddd'
package 'ddd-doc'
package 'gdb'
package 'gdb-doc'
package 'valgrind'
package 'visualvm'

## Utilities
package 'firefox'
package 'gnome-terminal'

package 'byobu'
package 'screen'
