include_cookbook 'xdg-desktop'

remote_file '/usr/share/icons/hicolor/scalable/apps/ioi18.svg' do
  owner 'root'
  group 'root'
  mode '644'
end

desktop_entry 'ioi18-cms' do
  display_name 'Grading System'
  icon '/usr/share/icons/hicolor/scalable/apps/ioi18.svg'
  exec "x-www-browser #{node.dig(:contestant, :cms_uri)}"
  categories %w(Education)
end

desktop_entry 'cppreference' do
  display_name 'C++/C Reference'
  icon 'html'
  exec 'x-www-browser /usr/share/cppreference/doc/html/en/index.html'
  categories %w(Documentation)
end

desktop_entry 'python3-doc' do
  display_name 'Python 3 Documentation'
  icon 'html'
  exec 'x-www-browser /usr/share/doc/python3/html/index.html'
  categories %w(Documentation)
end

desktop_entry 'python2-doc' do
  display_name 'Python 2 Documentation'
  icon 'html'
  exec 'x-www-browser /usr/share/doc/python/html/index.html'
  categories %w(Documentation)
end

desktop_entry 'gdb-doc' do
  display_name 'GDB Documentation'
  icon 'html'
  exec 'x-www-browser /usr/share/doc/gdb-doc/html/gdb/index.html'
  categories %w(Documentation)
end

desktop_entry 'fp-docs' do
  display_name 'Free Pascal Documentation'
  icon 'html'
  exec 'x-www-browser /usr/share/doc/fp-docs/3.0.4/fpctoc.html'
  categories %w(Documentation)
end

desktop_entry 'openjdk-8-docs' do
  display_name 'OpenJDK 8 API Reference'
  icon 'html'
  exec 'x-www-browser /usr/share/doc/openjdk-8-doc/api/index.html'
  categories %w(Documentation)
end
