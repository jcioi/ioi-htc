package 'make'
package 'qemu-system-x86'
package 'qemu-utils'
package 'ovmf'
package 'libguestfs-tools'
package 'pigz'

include_cookbook 'packer'
include_cookbook 'apt-cacher-ng'

execute "usermod -a -G kvm ioi" do
  only_if "! getent group kvm | cut -d: -f4 | tr , '\\n' | grep -Fxq ioi"
end
