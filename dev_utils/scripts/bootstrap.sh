#!/bin/bash

mqhost="mq"
s3host="s3"

if [ ! -f /.dockerenv ]; then
    echo "I'm loose in the world!";
    mqhost="localhost"
    s3host="localhost"
fi

get=""
if [ "$(command -v curl)" ]; then
    get="curl"
elif [ "$(command -v wget)" ]; then
    get="wget"
else
    echo "Neither curl or wget found, exiting"
    exit 1
fi

pubkey=""
#parse input
while (( "$#" )); do
    case "$1" in
        -p|--pubkey)
            shift
            if [ ! -f "$1" ]
            then
                echo "ERROR: '$1' is not a file"
                exit 1
            fi
            pubkey="$1"
            ;;
    esac
    shift
done

cd /tmp || exit 1

ARCH=$(uname -sm | sed 's/ /_/' | tr '[:upper:]' '[:lower:]')

# Check for needed commands
C4GH=$(command -v crypt4gh)
if [ ! "$C4GH" ] || crypt4gh --version | grep -q version ; then
    echo "crypt4gh not found, downloading v1.5.3"
    if [ $get == "curl" ]; then
        curl -sL "https://github.com/neicnordic/crypt4gh/releases/download/v1.5.3/crypt4gh_$ARCH.tar.gz" | tar zxf - -C /tmp
    else
        wget -qO- "https://github.com/neicnordic/crypt4gh/releases/download/v1.5.3/crypt4gh_$ARCH.tar.gz" | tar zxf  - -C /tmp
    fi
fi
S3=$(command -v s3cmd)
if [ ! "$S3" ] || [ "$(s3cmd --version | head -n1 | cut -d" " -f3 | sed 's/\.//g')" -lt 220 ]; then
    echo "s3cmd not found, downloading v2.3.0"
    if [ $get == "curl" ]; then
        curl -sL "https://github.com/s3tools/s3cmd/releases/download/v2.3.0/s3cmd-2.3.0.tar.gz" | tar zxf - -C /tmp
    else
        wget -qO- "https://github.com/s3tools/s3cmd/releases/download/v2.3.0/s3cmd-2.3.0.tar.gz" | tar zxf  - -C /tmp
    fi
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

# create files
for N in {1..5} ; do
    dd if=/dev/urandom of="/tmp/file$N" bs="$RANDOM"k count=1
done

filePaths=()
# encrypt and upload files for user 1
/tmp/crypt4gh generate -n user1 -p passwd1
for N in 1 2 3; do
    if [ "$N" -eq 3 ];then
        yes | /tmp/crypt4gh encrypt -f "file$N" -p user1.pub.pem
    else
        yes | /tmp/crypt4gh encrypt -f "file$N" -p "$pubkey"
    fi
    "$S3" -q --no-ssl --host="http://$s3host:9000" --host-bucket="http://$s3host:9000" --access_key="access" --secret_key="secretkey" put "file$N.c4gh" s3://inbox/user1/
    filePaths+=( "user1/file$N" )
done

# encrypt and upload files for user 2
/tmp/crypt4gh generate -n user2 -p passwd2
for N in 4 5 ; do
    yes | /tmp/crypt4gh encrypt -f file$N -p "$pubkey"
    "$S3" -q --no-ssl --host="http://$s3host:9000" --host-bucket="http://$s3host:9000" --access_key="access" --secret_key="secretkey" put "file$N.c4gh" s3://inbox/user2/subpath/
    filePaths+=( "user2/subpath/file$N" )
done

# trigger ingestion of uploaded files
user="user1"
for file in "${filePaths[@]} "; do
    f=$(basename "$file" | xargs )
    MD5=$(md5sum "$f.c4gh" | cut -d ' ' -f1)
    SHA=$(sha256sum "$f.c4gh" | cut -d ' ' -f1)
    if [ "$f" == "file4" ];then
        user="user2"
    fi
    curl -s -u test:test "$mqhost:15672/api/exchanges/test/sda/publish" \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -d'{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"1","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"ingest\",\"user\":\"'$user'\",\"filepath\":\"'"$file"'\",\"encrypted_checksums\":[{\"type\":\"sha256\",\"value\":\"'"$SHA"'\",\"type\":\"md5\",\"value\":\"'"$MD5"'\"}]}"}'
done
