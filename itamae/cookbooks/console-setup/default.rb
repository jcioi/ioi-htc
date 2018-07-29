node.reverse_merge!(
  console_setup: {
    keyboard: {
      model: 'pc105',
      layout: 'us',
      variant: '',
      options: '',
    }
  }
)

template '/etc/default/keyboard' do
  owner 'root'
  group 'root'
  mode '644'
end
