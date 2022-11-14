#!/bin/bash

mqhost="mq"
s3host="s3"
cegahost="cegamq"

if [ ! -f /.dockerenv ]; then
    echo "I'm loose in the world!";
    mqhost="localhost"
    s3host="localhost"
    cegahost="localhost"
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

if [ -f "/keys/repo.pub.pem" ]; then
    pubkey="/keys/repo.pub.pem"
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
timestamp="$(date +%s)"
# create files
for N in {1..5} ; do
    dd if=/dev/urandom of="/tmp/file$N-$timestamp" bs="$RANDOM"k count=1
done

filePaths=()
# encrypt and upload files for user 1
/tmp/crypt4gh generate -n user1 -p passwd1
for N in 1 2 3; do
    if [ "$N" -eq 3 ];then
        yes | /tmp/crypt4gh encrypt -f "file$N-$timestamp" -p user1.pub.pem
    else
        yes | /tmp/crypt4gh encrypt -f "file$N-$timestamp" -p "$pubkey"
    fi
    "$S3" -q --no-ssl --host="http://$s3host:9000" --host-bucket="http://$s3host:9000" --access_key="access" --secret_key="secretkey" put "file$N-$timestamp.c4gh" s3://inbox/user1/
    filePaths+=( "user1/file$N-$timestamp.c4gh" )
done

# encrypt and upload files for user 2
for N in 4 5 ; do
    yes | /tmp/crypt4gh encrypt -f "file$N-$timestamp" -p "$pubkey"
    "$S3" -q --no-ssl --host="http://$s3host:9000" --host-bucket="http://$s3host:9000" --access_key="access" --secret_key="secretkey" put "file$N-$timestamp.c4gh" s3://inbox/user2/subpath/
    filePaths+=( "user2/subpath/file$N-$timestamp.c4gh" )
done

# trigger ingestion of uploaded files
user="user1"
stableids_user1=()
stableids_user2=()
for file in "${filePaths[@]} "; do
    f=$(basename "$file" | xargs )
    echo "#$f#"
    MD5=$(md5sum "$f" | cut -d ' ' -f1)
    SHA=$(sha256sum "$f" | cut -d ' ' -f1)
    if [ "$f" == "file4-$timestamp.c4gh" ];then
        user="user2"
    fi
    curl -s -u test:test "$cegahost:15671/api/exchanges/lega/localega.v1/publish" \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -d'{"vhost":"lega","name":"localega.v1","properties":{"delivery_mode":2,"correlation_id":"1","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files.inbox","payload_encoding":"string","payload":"{\"type\":\"ingest\",\"user\":\"'$user'\",\"filepath\":\"'"$file"'\",\"encrypted_checksums\":[{\"type\":\"sha256\",\"value\":\"'"$SHA"'\"},{\"type\":\"md5\",\"value\":\"'"$MD5"'\"}]}"}'
    sleep 5
    # Check that the ingested file showed up in the database
	RETRY_TIMES=0
	statusindb=''
	until [ -n "$statusindb" ]; do
		statusindb=$(PGPASSWORD=lega_in psql -h db -U lega_in lega -t -A -c "SELECT id FROM local_ega.main where submission_file_path='$file' AND status='COMPLETED';")
		echo "Waiting to find id in DB"
        sleep 10
		RETRY_TIMES=$((RETRY_TIMES + 1))

		if [ "$RETRY_TIMES" -eq 5 ]; then
			echo "Timed out waiting correct status in database, aborting"
			break
		fi
	done
    # In case the file does not appear in the DB
    # continue with the next one
    if [ "$statusindb" = "" ]; then
        continue
    fi

    # Calculate checksums of the decrypted file
    suffix=".c4gh"
    decrfile=${f%$suffix}
    decrypted_sha=$(sha256sum "$decrfile" | cut -d ' ' -f1)
    decrypted_md5=$(md5sum "$decrfile" | cut -d ' ' -f1)

    # Create random accession id
    access=$(printf "EGAF%05d%06d" "$RANDOM" "$count")

    # Start finalize
    curl -u test:test "$mqhost:15672/api/exchanges/test/sda/publish" \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"1","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"accession\",\"user\":\"'"$user"'\",\"filepath\":\"'"$file"'\",\"accession_id\":\"'"$access"'\",\"decrypted_checksums\":[{\"type\":\"sha256\",\"value\":\"'"$decrypted_sha"'\"},{\"type\":\"md5\",\"value\":\"'"$decrypted_md5"'\"}]}"}'

    # Check in the DB that the file got stable_id
    RETRY_TIMES=0
    stableid=''
    until [ -n "$stableid" ]; do
		stableid=$(PGPASSWORD=lega_in psql -h db -U lega_in lega -t -A -c "SELECT stable_id FROM local_ega.main where submission_file_path='$file' AND status='READY';")
		echo "waiting to find stable_id in DB"
        sleep 10
		RETRY_TIMES=$((RETRY_TIMES + 1))

		if [ "$RETRY_TIMES" -eq 5 ]; then
			echo "Timed out waiting status ready in database"
			break
		fi
	done

    # In case the file does not appear with status READY in DB
    # continue with the next file
    if [ "$stableid" = "" ]; then
        continue
    fi

    # Add stable_ids in a list for each user
    if [ "$user" = "user1" ]; then
        stableids_user1+=("\\\"$access\\\"")
    else
        stableids_user2+=("\\\"$access\\\"")
    fi
done

# Start mapping for user 1
echo "Mapping started for user 1"
printf -v ids_user1 ',%s' "${stableids_user1[@]}"
ids_user1=${ids_user1:1}

curl -vvv -u test:test "$mqhost:15672/api/exchanges/test/sda/publish" \
-H 'Content-Type: application/json;charset=UTF-8' \
--data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"1","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"mapping\",\"dataset_id\":\"EGAD00123456780\",\"accession_ids\":['"$ids_user1"']}"}'
echo "Mapping is done for user 1"

# Start mapping for user 2
echo "Mapping started for user 2"
printf -v ids_user2 ',%s' "${stableids_user2[@]}"
ids_user2=${ids_user2:1}

curl -vvv -u test:test "$mqhost:15672/api/exchanges/test/sda/publish" \
-H 'Content-Type: application/json;charset=UTF-8' \
--data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"1","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"mapping\",\"dataset_id\":\"EGAD00123456790\",\"accession_ids\":['"$ids_user2"']}"}'
echo "Mapping is done for user 2"
