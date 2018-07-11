GZIP=pigz

export PACKER_KEY_INTERVAL = 10ms

preview: preview.ova
.PHONY: preview

%.json: %.yaml
	ruby -rjson -ryaml -e 'File.write(ARGV[1], JSON.dump(YAML.load_file(ARGV[0])))' $< $@

%.qcow2: %.json %.rebuild
	rm -rf tmp/$$(basename -s .qcow2 $@)
	time packer build $<

base.qcow2: d-i/bionic/preseed.cfg
preview.qcow2: base.qcow2

# touch this file to rebuild the corresponding %.qcow2
%.rebuild:
	touch $@

%.vmdk: %.qcow2
	qemu-img convert -O vmdk $< $@

%.vmdk.gz: %.vmdk
	$(GZIP) -c -- $< > $@

%.ova: %.ovf %.vmdk.gz
	tar cf $@ -- $^
