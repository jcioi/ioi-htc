node.reverse_merge!(
  unbound: {
    root_trust_anchor_update: false,
  },
)

# Disable overriding resolv.conf
template '/etc/default/unbound' do
  owner 'root'
  group 'root'
  mode  '0644'
end

package 'unbound' do
end

unless node[:unbound][:root_trust_anchor_update]
  file '/etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf' do
    action :delete
  end
end

