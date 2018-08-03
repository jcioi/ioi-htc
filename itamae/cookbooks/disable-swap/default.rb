execute 'sed -i"" -e \'/\sswap\s/d\' /etc/fstab' do
  only_if "grep '\\sswap\\s' /etc/fstab"
end

execute 'swapoff -a' do
  only_if 'grep / /proc/swaps'
end
