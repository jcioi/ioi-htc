#!/bin/sh

set -ue

temp_dir="$(mktemp -d --tmpdir -- 'ioi-export.XXXXXXXXXX')"
date_repr="$(date +%m%d)"
time_repr="$(date +%H%M)"
sub_dirname="${date_repr}-${time_repr}-submissons"
zip_fname="${date_repr}-${time_repr}-submissons.zip"

mkdir -p "$temp_dir"
cd "$temp_dir"

echo "exporting submissions"
/usr/bin/ioi-cms-venv cmsExportSubmissions -y --filename "{task}/{id:05d}_{score:03.0f}_{file}{ext}" "$sub_dirname" > /dev/null

echo "zipping submission files"
zip -r "$zip_fname" "$sub_dirname" > /dev/null

echo "transfering zip file"
aws s3 cp "$zip_fname" "$ZIP_DESTINATION/$date_repr/"
rm -r "$temp_dir"
