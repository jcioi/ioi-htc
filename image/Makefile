GZIP=pigz
SPARSIFY=true

export PACKER_KEY_INTERVAL = 10ms

preview: preview.ova
.PHONY: preview

publish-preview: preview.ova
	./publish.sh $< ioi18-$$(date +%Y%m%d).ova
.PHONY: publish-preview

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

.SECONDARY:
FORCE:
.PHONY: FORCE
