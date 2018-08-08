#!/bin/bash

set -eux -o pipefail

PUBLIC_S3_BUCKET_NAME=ioi18-public-images-eu
PUBLIC_S3_BUCKET_REGION=eu-west-1
PUBLIC_CF_DISTRIBUTION=EHY9B446H8L32

SRC=$1
DST=$2

cat "$SRC" | sha256sum > "$SRC.sha256sum"
sed -i "s|-|$DST|" "$SRC.sha256sum"

aws s3 cp "$SRC" "s3://${PUBLIC_S3_BUCKET_NAME}/$DST" --acl public-read --region "${PUBLIC_S3_BUCKET_REGION}" --endpoint-url http://s3-accelerate.dualstack.amazonaws.com
aws s3 cp "$SRC.sha256sum" "s3://${PUBLIC_S3_BUCKET_NAME}/$DST.sha256sum" --acl public-read --region ${PUBLIC_S3_BUCKET_REGION} --endpoint-url http://s3-accelerate.dualstack.amazonaws.com

aws cloudfront create-invalidation --distribution-id "${PUBLIC_CF_DISTRIBUTION}" --paths "/$DST" "/$DST.sha256sum"
