# Testing the SDA pipeline

## Testing the System at Once
To test the system run the bootstrap container with bootstrap.sh

## Testing the System Stepwise
Replace the bootstrap.sh with the script stepwiseboots.sh rerun the container with `docker-compose up bootstrap`

To see the output of the script see the logs of the `bs` container with the command `docker logs bs -f`.
