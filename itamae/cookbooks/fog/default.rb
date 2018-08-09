include_recipe './install.rb'

file '/var/www/fog/service/ipxe/refind.conf' do
  action :edit

  block do |content|
    content.gsub!(/^scanfor\s.*$/, 'scanfor internal')
  end
end
