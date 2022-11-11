#!/bin/bash

if [ "$(command -v curl)" ]; then
    echo "Using curl"
else
    echo "curl not found, exiting"
    exit 1
fi

ARCH=$(uname -sm | sed 's/ /_/' | tr '[:upper:]' '[:lower:]')
cd /tmp || exit 1
# Check for needed commands
C4GH=$(command -v crypt4gh)
if [ ! "$C4GH" ] || crypt4gh --version | grep -q version ; then
    echo "crypt4gh not found, downloading v1.5.3"
    curl -sL "https://github.com/neicnordic/crypt4gh/releases/download/v1.5.3/crypt4gh_$ARCH.tar.gz" | tar zxf - -C /tmp
fi
S3=$(command -v s3cmd)
if [ ! "$S3" ] || [ "$(s3cmd --version | head -n1 | cut -d" " -f3 | sed 's/\.//g')" -lt 220 ]; then
    echo "s3cmd not found, downloading v2.3.0"
    curl -sL "https://github.com/s3tools/s3cmd/releases/download/v2.3.0/s3cmd-2.3.0.tar.gz" | tar zxf - -C /tmp
    S3="/tmp/s3cmd-2.3.0/s3cmd"
fi

# create repository crypt4gh keys
if [ -z "$pubkey" ];then
    echo "no public key supplied, creating repository key"
    /tmp/crypt4gh generate -n repo -p repoPass
    if [ -f /.dockerenv ]; then
        cp /tmp/repo* /keys
        pubkey="/keys/repo.pub.pem"
    else
        pubkey="/tmp/repo.pub.pem"
    fi
fi

tail -f /dev/null
