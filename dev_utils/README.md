# Local testing howto

## Logging
The logging compose contains elasticsearch, kibana and filebeat. The configuration of filebeat can be found in `filebeat.yml` file

### Start logging compose
In order to get logs from the containers in the ELK stack, start the logging compose using
```sh
docker-compose -f docker-compose-logging up -d
```
Elastic search needs some time to get started. You can check the logs using
```sh
docker logs dev_utils-elasticsearch-1
```
while for Kibana you can use
```sh
docker logs dev_utils-kibana-1
```
Once both are up and running, go to kibana UI in a browser, at `localhost:5601` and create a new index under `Management`/`Index Patterns`. The name of the pattern should be `filebeat-*` and the Time Filter field name `@timestamp`.

### Start sda pipeline compose
Now that the ELK stack is setup, yu can start the sda pipeline, using
```sh
docker-compose -f <sda-pipeline.yaml> up -d
```

Under the `Discover` tab, you should be able to see the logs for all containers using an image that starts with `sda-` as well as `minio`