skel = '/etc/skel'

desktop_shortcuts = {
  nil => %w[
    /usr/local/share/applications/ioi18-cms.desktop
  ],
  'Editors & IDEs' => %w[
    /usr/share/applications/atom.desktop
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

%w[
  Desktop
  Templates
].each do |_|
  directory "#{skel}/#{_}" do
    owner 'root'
    group 'root'
    mode '755'
  end
end

desktop_shortcuts.each do |folder, entries|
  if folder
    directory "#{skel}/Desktop/#{folder}" do
      owner 'root'
      group 'root'
      mode '755'
    end
  end

  entries.each do |entry|
    dest = "#{skel}/Desktop/#{folder + ?/ if folder}#{entry.split('/').last}"
    execute "create #{dest}" do
      command "install -T #{entry.shellescape} #{dest.shellescape}"
      not_if "diff #{entry.shellescape} #{dest.shellescape}"
    end
  end
end

[
  'Text File.txt',
].each do |_|
  file "#{skel}/Templates/#{_}" do
    action :create
    owner 'root'
    group 'root'
    mode '644'
  end
end
