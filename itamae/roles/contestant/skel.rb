skel = '/etc/skel'

desktop_shortcuts = {
  'Editors & IDEs' => %w[
    /usr/share/applications/codeblocks.desktop
    /usr/share/applications/emacs25.desktop
    /usr/share/applications/geany.desktop
    /usr/share/applications/gedit.desktop
    /usr/share/applications/gvim.desktop
    /usr/share/applications/lazarus-1.8.2.desktop
    /usr/share/applications/org.kde.kate.desktop
    /usr/share/applications/org.kde.kdevelop.desktop
    /usr/local/share/applications/eclipse.desktop
    /usr/local/share/applications/intellij-idea-community.desktop
  ],
  'Docs' => %w[
    /usr/local/share/applications/cppreference.desktop
    /usr/local/share/applications/python3-doc.desktop
    /usr/local/share/applications/python2-doc.desktop
    /usr/local/share/applications/fp-docs.desktop
    /usr/local/share/applications/openjdk-8-docs.desktop
  ],
  'Utilities' => %w[
    /usr/share/applications/byobu.desktop
    /usr/share/applications/gnome-terminal.desktop
    /usr/share/applications/org.kde.konsole.desktop
    /usr/share/applications/ddd.desktop
    /usr/share/applications/visualvm.desktop
  ],
}

directory "#{skel}/Desktop" do
  owner 'root'
  group 'root'
  mode '755'
end

desktop_shortcuts.each do |name, entries|
  directory "#{skel}/Desktop/#{name}" do
    owner 'root'
    group 'root'
    mode '755'
  end

  entries.each do |entry|
    dest = "#{skel}/Desktop/#{name}/#{entry.split('/').last}"
    execute "create #{dest}" do
      command "install -T #{entry.shellescape} #{dest.shellescape}"
      not_if "diff #{entry.shellescape} #{dest.shellescape}"
    end
  end
end