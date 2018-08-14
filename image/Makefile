GZIP=pigz
SPARSIFY=true

BRIDGE_CONTESTANT=br-ioi-arena
MAC_CONTESTANT=52:54:00:1f:2f:3f

export PACKER_KEY_INTERVAL = 10ms

preview: preview.ova
.PHONY: preview

publish-preview: preview.ova
	./publish.sh $< ioi18-$$(date +%Y%m%d).ova
.PHONY: publish-preview

contestant: contestant.qcow2
.PHONY: contestant

run-contestant: contestant.qcow2.overlay
	sudo qemu-system-x86_64 -machine accel=kvm -m 4G -smp 2,cores=2 -cpu host \
		-drive if=virtio,file=$<,format=qcow2 \
		-display sdl -vga virtio \
		-netdev bridge,id=net0,br=${BRIDGE_CONTESTANT} -device virtio-net-pci,netdev=net0,mac=${MAC_CONTESTANT},bootindex=1 \
		-bios OVMF.fd -boot menu=on
.PNONY: run-contestant


%.json: %.yaml
	ruby -rjson -ryaml -e 'File.write(ARGV[1], JSON.dump(YAML.load_file(ARGV[0])))' $< $@

%.qcow2: %.json %.rebuild | timestamp
	rm -rf tmp/$$(basename -s .qcow2 $@)
	time packer build $<
	$(SPARSIFY) && sudo virt-sparsify --in-place $@

base.qcow2: d-i/bionic/preseed.cfg
preview.qcow2: base.qcow2

# touch this file to rebuild the corresponding %.qcow2
%.rebuild:
	touch $@

timestamp: FORCE
	(TZ=Asia/Tokyo date +"%FT%T+0900"; git rev-parse @) > $@

%.vmdk: %.qcow2
	qemu-img convert -O vmdk $< $@

%.vmdk.gz: %.vmdk
	$(GZIP) -c -- $< > $@

%.ova: %.ovf %.vmdk.gz
	tar cf $@ -- $^

%.qcow2.overlay: %.qcow2 FORCE
	qemu-img create -f qcow2 -b $< $@

.SECONDARY:
FORCE:
.PHONY: FORCE
