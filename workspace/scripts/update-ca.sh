#!/bin/bash

set -o errexit
set -o nounset
ORIGINCRTDIR="/usr/share/ca-certificates/mozilla"
TARGETPEMDIR="/etc/ssl/certs"


# link pem -> crt
for crt in $ORIGINCRTDIR/*.crt;
do
    file=$(basename $crt)
    name=${file%.crt}
    ln -svf $crt $TARGETPEMDIR/$name.pem
    openssl rehash
done
