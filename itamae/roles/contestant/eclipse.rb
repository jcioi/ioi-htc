execute 'install eclipse' do
  script = <<EOF
tmp=$(mktemp --tmpdir "XXXXXXXXX.tar.gz")
mkdir -p /opt/eclipse
curl -fLsS -o "$tmp" http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-java-photon-R-linux-gtk-x86_64.tar.gz
echo "e6f5ee4e5ced59d2cf6a9b7a992b7d01eb71480cd2353844ba47eb5c55a41816 $tmp" | sha256sum -c
tar zxf "$tmp" -C /opt/eclipse --strip=1
EOF

  command "bash -exo pipefail -c #{script.shellescape}"
  not_if 'test -e /opt/eclipse/eclipse'
end

link '/usr/local/bin/eclipse' do
  to '/opt/eclipse/eclipse'
end

define :eclipse_plugin, units: [] do
	units = params[:units]

  p2director = "eclipse -nosplash -application org.eclipse.equinox.p2.director -r http://download.eclipse.org/releases/photon/"

  execute "eclipse installIU: #{params[:name]}" do
    command "#{p2director} -i #{units.join(?,).shellescape}"
    not_if <<EOF
list=$(#{p2director} -lir)
for unit in #{units.shelljoin}; do
  echo "$list" | grep -qF "$unit/" || exit 1
done
EOF
  end
end

eclipse_plugin 'cdt' do
  units %w[
    #org.eclipse.cdt.arduino.feature.group
    #org.eclipse.cdt.autotools.feature.group
    #org.eclipse.cdt.build.crossgcc.feature.group
    #org.eclipse.cdt.cmake.feature.group
    #org.eclipse.cdt.debug.gdbjtag.feature.group
    org.eclipse.cdt.debug.standalone.feature.group
    org.eclipse.cdt.debug.ui.memory.feature.group
    #org.eclipse.cdt.docker.launcher.feature.group
    org.eclipse.cdt.feature.group
    #org.eclipse.cdt.launch.remote.feature.group
    #org.eclipse.cdt.launch.serial.feature.feature.group
    #org.eclipse.cdt.meson.feature.group
    #org.eclipse.cdt.mylyn.feature.group

    org.eclipse.cdt.testsrunner.feature.feature.group
    org.eclipse.cdt.gnu.multicorevisualizer.feature.group
  ].reject {|s| s =~ /^#/ }
end

eclipse_plugin 'linuxtools' do
  units %w[
    org.eclipse.linuxtools.cdt.libhover.devhelp.feature.feature.group
    org.eclipse.linuxtools.cdt.libhover.feature.feature.group
    #org.eclipse.linuxtools.changelog.c.feature.group
    #org.eclipse.linuxtools.gcov.feature.group
    org.eclipse.linuxtools.gprof.feature.feature.group
    #org.eclipse.linuxtools.rpm.feature.group
    org.eclipse.linuxtools.valgrind.feature.group
  ].reject {|s| s =~ /^#/ }
end

include_cookbook 'xdg-desktop'

desktop_entry 'eclipse' do
  display_name 'Eclipse'
  comment 'Eclipse Integrated Development Environment'
  icon '/opt/eclipse/icon.xpm'
  exec '/usr/local/bin/eclipse'
  categories %w(Development IDE Java)
end
