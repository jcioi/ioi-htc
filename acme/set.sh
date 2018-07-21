#!/bin/bash -xe
tmpdir=/tmp/ioi-htc-acme-set-$$
cn=$1
mkdir -p $tmpdir
bundle exec acmesmith save --key-file=${tmpdir}/key --fullchain-file=${tmpdir}/fullchain --chain-file=${tmpdir}/chain --certificate-file=${tmpdir}/cert ${cn}
cd ../itamae
bundle exec itamae-secrets set acme_key_${cn} < ${tmpdir}/key
bundle exec itamae-secrets set acme_cert_${cn} < ${tmpdir}/cert
bundle exec itamae-secrets set acme_fullchain_${cn} < ${tmpdir}/fullchain
bundle exec itamae-secrets set acme_chain_${cn} < ${tmpdir}/chain
rm -rf ${tmpdir}/
