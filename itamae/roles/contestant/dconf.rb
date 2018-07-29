include_cookbook 'dconf'

dconf_defaults 'disable-powersaving' do
  values(
    '/org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type' => 'nothing',
    '/org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type' => 'nothing',
    '/org/gnome/settings-daemon/plugins/power/idle-dim' => false,
    '/org/gnome/settings-daemon/plugins/power/power-button-action' => 'nothing',
    '/org/gnome/desktop/session/idle-delay' => :'uint32 0',
    '/org/gnome/desktop/session/lock-enabled' => false,
  )
  lock true
end
