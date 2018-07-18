include_cookbook 'xdg-desktop'

desktop_entry 'cppreference' do
  display_name 'C++/C Reference'
  icon 'html'
  exec 'x-www-browser /opt/cppreference/reference/en/index.html'
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
