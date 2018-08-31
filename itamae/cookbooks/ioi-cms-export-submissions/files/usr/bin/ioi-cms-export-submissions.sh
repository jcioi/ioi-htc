#!/bin/sh

set -ue

temp_dir="$(mktemp -d --tmpdir -- 'ioi-export.XXXXXXXXXX')"
sub_dir="$temp_dir/submissions"
date_repr="$(date +%Y-%m%d-%H%M)"
zip_path="$temp_dir/submissions-$date_repr.zip"

mkdir -p "$temp_dir"

echo "exporting submissions"
/usr/bin/ioi-cms-venv cmsExportSubmissions -y --filename "{task}/{id:05d}_{score:03.0f}_{file}{ext}" "$sub_dir"

echo "zipping submission files"
zip -r "$zip_path" "$sub_dir"

echo "transfering zip file"
aws s3 cp "$zip_path" "$ZIP_DESTINATION"
rm -r "$temp_dir"
