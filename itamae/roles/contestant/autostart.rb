%w[
  pulseaudio
  update-notifier
].each do |_|
  statoverride "/etc/xdg/autostart/#{_}.desktop" do
    owner 'root'
    group 'root'
    mode '640'
  end
end

%w[
  evolution-addressbook-factory
  evolution-calendar-factory
  evolution-source-registry
].each do |_|
  link "/etc/systemd/user/#{_}.service" do
    to '/dev/null'
  end
end

%w[
  anacron
  cron
  wpa_supplicant
].each do |_|
  link "/etc/systemd/system/#{_}.service" do
    to '/dev/null'
  end
end
