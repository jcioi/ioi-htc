node.reverse_merge!(
  swap: {
    size: 0,
    path: '/swapfile',
  },
)

if node.dig(:swap, :size) > 0

  swapfile = node.dig(:swap, :path)
  swapsize = node.dig(:swap, :size)

  execute "fallocate -l #{swapsize} #{swapfile} && mkswap #{swapfile}" do
    not_if %{test "$(stat -c %s #{swapfile})" -eq #{swapsize}}
  end

  file swapfile do
    owner 'root'
    group 'root'
    mode '600'
  end

  execute "echo '#{swapfile} swap swap defaults 0 0' >> /etc/fstab" do
    not_if "grep '\\sswap\\s' /etc/fstab"
  end

else

  execute 'sed -i"" -e \'/\sswap\s/d\' /etc/fstab' do
    only_if "grep '\\sswap\\s' /etc/fstab"
  end

  execute 'swapoff -a' do
    only_if 'grep / /proc/swaps'
  end

end
