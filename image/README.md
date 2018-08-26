## Prerequisites
See `../itamae/roles/image-builder`

## Tasks

### Contestant image for practice
```
touch preview.rebuild  # if need rebuilding

make preview  # generates preview.ova
make publish-preview  # uploads OVA to S3
```

### Contestant image for on-site
```
touch contestant.rebuild  # if need force rebuilding

make contestant  # generates contestant.qcow2
make run-contestant  # runs QEMU for capturing image by FOG
```

### CMS Worker image for on-site
```
touch cmsworker.rebuild  # if need force rebuilding

make cmsworker  # generates cmsworker.qcow2
make run-cmsworker  # runs QEMU for capturing image by FOG
```
