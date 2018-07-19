directory '/usr/local/share/applications' do
  owner 'root'
  group 'root'
  mode '755'
end

define :desktop_entry, display_name: nil, comment: nil, icon: nil, exec: nil, terminal: false, categories: [] do
  display_name = params[:display_name] || fail
  comment = params[:comment] || display_name
  icon = params[:icon] || fail
  exec = params[:exec] || fail
  terminal = !!params[:terminal]
  categories = [*params[:categories]].map {|s| "#{s};" }.join

  file "/usr/local/share/applications/#{params.fetch(:name)}.desktop" do
    owner 'root'
    group 'root'
    mode '644'
    content <<EOF
[Desktop Entry]
Type=Application
Name=#{display_name}
Comment=#{comment}
Icon=#{icon}
Exec=#{exec}
Terminal=#{terminal}
Categories=#{categories}
EOF
  end
end
