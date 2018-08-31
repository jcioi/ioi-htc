#!/bin/sh

set -ue

temp_dir="$(mktemp -d --tmpdir -- 'ioi-export.XXXXXXXXXX')"
date_repr="$(date +%Y-%m%d-%H%M)"
sub_dirname="submissions-$date_repr"
zip_fname="submissions-$date_repr.zip"

mkdir -p "$temp_dir"
cd "$temp_dir"

echo "exporting submissions"
/usr/bin/ioi-cms-venv cmsExportSubmissions -y --filename "{task}/{id:05d}_{score:03.0f}_{file}{ext}" "$sub_dirname"

echo "zipping submission files"
zip -r "$zip_fname" "$sub_dirname"

echo "transfering zip file"
aws s3 cp "$zip_fname" "$ZIP_DESTINATION"
rm -r "$temp_dir"
