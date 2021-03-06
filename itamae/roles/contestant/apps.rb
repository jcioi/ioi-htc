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
include_recipe './atom.rb'
include_recipe './sublime_text.rb'

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
package 'gnome-terminal'
package 'konsole'
package 'xterm'

package 'byobu'
package 'mc'
package 'screen'

package 'gnome-calculator'

## Extra documents
package 'cppreference-doc-en-html'

## For GNOME
package 'evince'
package 'gkbd-capplet'
package 'nautilus-extension-gnome-terminal'
package 'gnome-tweaks'

## Firefox
package 'firefox'
package 'xvfb'

execute 'firefox -CreateProfile' do
  command 'env HOME=/etc/skel xvfb-run firefox -CreateProfile "ioi.default /etc/skel/.mozilla/firefox/ioi.default"'
  not_if 'test -e /etc/skel/.mozilla/firefox/ioi.default'
end

template '/etc/skel/.mozilla/firefox/ioi.default/prefs.js' do
  owner 'root'
  group 'root'
  mode '0600'
end
