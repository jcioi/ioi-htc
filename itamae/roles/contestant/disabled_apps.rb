disabled_apps = %w[
  gnome-bluetooth-panel
  gnome-online-accounts-panel
  gnome-power-panel
  gnome-privacy-panel
  gnome-removable-media-panel
  gnome-sharing-panel
  gnome-sound-panel
  gnome-thunderbolt-panel
  gnome-user-accounts-panel
  gnome-wacom-panel
  gnome-wifi-panel

  software-properties-gtk
  update-manager
]

unless node.dig(:contestant, :preview)
  disabled_apps << 'gnome-network-panel'
end

disabled_apps.each do |_|
  statoverride "/usr/share/applications/#{_}.desktop" do
    owner 'root'
    group 'root'
    mode '640'
  end
end
