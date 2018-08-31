GZIP=pigz
SPARSIFY=true

BRIDGE_CONTESTANT=br-arena
MAC_CONTESTANT=52:54:00:1f:2f:3f
BRIDGE_CMSWORKER=br-srv
MAC_CMSWORKER_DEV=52:54:00:7e:8e:9e
MAC_CMSWORKER_PRD=52:54:00:4d:5d:6d

export PACKER_KEY_INTERVAL = 10ms

preview: preview.ova
.PHONY: preview

publish-preview: preview.ova
	./publish.sh $< ioi18-$$(date +%Y%m%d).ova
.PHONY: publish-preview

contestant: contestant.qcow2
.PHONY: contestant

cmsworker-dev: cmsworker-dev.qcow2
cmsworker-prd: cmsworker-prd.qcow2
.PHONY: cmsworker-dev cmsworker-prd

run-contestant: contestant.qcow2.overlay
	sudo ./run-qemu.sh $< ${BRIDGE_CONTESTANT} ${MAC_CONTESTANT}
.PNONY: run-contestant

run-cmsworker-dev: cmsworker-dev.qcow2.overlay
	sudo ./run-qemu.sh $< ${BRIDGE_CMSWORKER} ${MAC_CMSWORKER_DEV}
run-cmsworker-prd: cmsworker-prd.qcow2.overlay
	sudo ./run-qemu.sh $< ${BRIDGE_CMSWORKER} ${MAC_CMSWORKER_PRD}
.PNONY: run-cmsworker-dev run-cmsworker-prd

base.qcow2: d-i/bionic/preseed.cfg
base-efi.qcow2: d-i/bionic/preseed-efi.cfg
preview.qcow2: base.qcow2 preview.attrs.json
contestant.qcow2: base-efi.qcow2 contestant.attrs.json
cmsworker-dev.qcow2: base-efi.qcow2 cmsworker-dev.attrs.json
cmsworker-prd.qcow2: base-efi.qcow2 cmsworker-prd.attrs.json

%.json: %.yaml
	ruby -rjson -ryaml -e 'File.write(ARGV[1], JSON.dump(YAML.load_file(ARGV[0])))' $< $@

%.qcow2: %.json %.rebuild | timestamp
	rm -rf tmp/$$(basename -s .qcow2 $@)
	time packer build $<
	$(SPARSIFY) && sudo virt-sparsify --in-place $@

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
