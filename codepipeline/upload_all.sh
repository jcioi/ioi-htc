#!/bin/bash
set -x
set -e
cd $(dirname $0)
for x in pipelines/*.rb; do
  bundle exec ruby upload.rb $(basename $x)
done
