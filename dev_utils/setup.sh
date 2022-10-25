#!/bin/bash

## Create test files

mkdir -p test_files keys
for k in file1 file2; do
    dd if=/dev/random of=test_files/user1"$k" count=1 bs=$(( 1024 * 1024 *  1 )) iflag=fullblock;
    dd if=/dev/random of=test_files/user2"$k" count=1 bs=$(( 1024 * 1024 *  1 )) iflag=fullblock;
done

## Deploy the pipeline stack and prepare for file submission

docker compose up -d

RETRY_TIMES=0
for p in db mq s3 ingest verify finalize mapper intercept; do
    until docker ps -f name="$p" --format "{{.Status}}" | grep "Up"
    do echo "waiting for $p to become ready"
        RETRY_TIMES=$((RETRY_TIMES+1));
        if [ "$RETRY_TIMES" -eq 30 ]; then
            # Time out
            docker logs "$p"
            exit 1;
        fi
        sleep 10
    done
done

# Show running containers
docker ps

## Create system state

# Function to completely ingest a file
function ingest_file () {
    FILE="$1"
    userName="$2"
    count="$3"

    SHA=$(sha256sum "$FILE" | awk '{print $1;}')
    MD5=$(md5sum "$FILE" | awk '{print $1;}')
    decrypted_sha=$(sha256sum "${FILE%.c4gh}" | awk '{print $1;}')
    decrypted_md5=$(md5sum "${FILE%.c4gh}" | awk '{print $1;}')
	access=$(printf "EGAF%05d%06d" "$RANDOM" "$count")

    file=$userName/$(basename "$FILE")

    curl -u test:test 'localhost:15672/api/exchanges/test/sda/publish' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"'"$count"'","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"ingest\",\"user\":\"'"$userName"'\",\"filepath\":\"'"$file"'\",\"encrypted_checksums\":[{\"type\":\"sha256\",\"value\":\"'"$SHA"'\",\"type\":\"md5\",\"value\":\"'"$MD5"'\"}]}"}'

    RETRY_TIMES=0
    until docker logs --since 30s ingest 2>&1 | grep "File marked as archived"
    do
        echo "waiting for ingestion to complete"
        RETRY_TIMES=$((RETRY_TIMES+1));
        if [ $RETRY_TIMES -eq 30 ]; then
            echo "Ingest failed"
            exit 1
        fi
        sleep 10;
    done

    RETRY_TIMES=0
    until docker logs --since 30s verify 2>&1 | grep "File marked completed"
    do
        echo "waiting for verification to complete"
        RETRY_TIMES=$((RETRY_TIMES+1));
        if [ $RETRY_TIMES -eq 30 ]; then
            echo "Verification failed"
            exit 1
        fi
        sleep 10;
    done

    RETRY_TIMES=0
    until docker logs --since 30s verify 2>&1 | grep "Removed file from inbox"
    do
        echo "waiting for removal of file from inbox"
        RETRY_TIMES=$((RETRY_TIMES+1));
        if [ $RETRY_TIMES -eq 20 ]; then
            echo "check file removed from inbox failed"
            exit 1
        fi
        sleep 10;
    done

    curl -u test:test 'localhost:15672/api/exchanges/test/sda/publish' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"'"$count"'","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"accession\",\"user\":\"'"$userName"'\",\"filepath\":\"'"$file"'\",\"accession_id\":\"'"$access"'\",\"decrypted_checksums\":[{\"type\":\"sha256\",\"value\":\"'"$decrypted_sha"'\"},{\"type\":\"md5\",\"value\":\"'"$decrypted_md5"'\"}]}"}'

    RETRY_TIMES=0
    until docker logs finalize 2>&1 | grep "Mark ready"
    do
        echo "waiting for finalize to complete"
        RETRY_TIMES=$((RETRY_TIMES+1));
        if [ $RETRY_TIMES -eq 30 ]; then
            echo "Finalize failed"
            exit 1
        fi
        sleep 10;
    done

    curl -vvv -u test:test 'localhost:15672/api/exchanges/test/sda/publish' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"vhost":"test","name":"sda","properties":{"delivery_mode":2,"correlation_id":"'"$count"'","content_encoding":"UTF-8","content_type":"application/json"},"routing_key":"files","payload_encoding":"string","payload":"{\"type\":\"mapping\",\"dataset_id\":\"EGAD00123456789\",\"accession_ids\":[\"'"$access"'\"]}"}'
}

# Ingest four files submitted by two different users
counter=1
for k in "1" "2"; do
    for l in "1" "2";do
        echo $counter
        ingest_file test_files/user"$k"file"$l".c4gh user"$k" $counter
        counter=$(($counter + 1))
    done
done

# Try to ingest an unencrypted file
ingest_file test_files/user1file1 user1 $counter
