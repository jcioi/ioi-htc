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

include_cookbook 'compilers'

## Base Desktop Environment
package 'ubuntu-desktop'
package 'fonts-noto'
package 'fonts-noto-cjk'

## Editors
package 'codeblocks'
package 'codeblocks-contrib'
package 'hunspell'  # for codeblocks (spellchecker plugin)
package 'geany'
package 'geany-plugins'
package 'emacs'
package 'gedit'
package 'joe'
package 'kate'
package 'kdevelop'
package 'lazarus'
package 'fpc-source'  # for lazarus
package 'nano'
package 'vim'
package 'vim-gtk3'

include_recipe './eclipse.rb'
include_recipe './intellij_idea.rb'

## Interpreters
package 'python'
package 'python-doc'
package 'python3'
package 'python3-doc'
package 'ruby'
package 'ruby2.5-doc'

## Debuggers
package 'cppcheck'
package 'ddd'
package 'ddd-doc'
package 'gdb'
package 'gdb-doc'
package 'valgrind'
package 'visualvm'

## Utilities
package 'firefox'
package 'gnome-terminal'
package 'konsole'
package 'xterm'

package 'byobu'
package 'mc'
package 'screen'

## Extra documents
package 'cppreference-doc-en-html'

include_recipe './desktop.rb'
