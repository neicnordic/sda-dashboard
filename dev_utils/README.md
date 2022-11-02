# Local testing howto

## Logging
The logging compose contains elasticsearch, kibana and filebeat. The configuration of filebeat can be found in `filebeat.yml` file

### Start the containers
In order to get logs from the containers in the ELK stack, start the compose using
```sh
docker-compose up -d
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
Now that the ELK stack is setup, you can start the sda pipeline, using
```sh
docker-compose -f <sda-pipeline.yaml> up -d
```

Under the `Discover` tab, you should be able to see the logs for all containers using an image that starts with `sda-` as well as `minio`


### View data in Grafana

#### Add sources
There are two different sources that can be added in the Grafana instance, the elastic search (containing the logs) and the database (containing information about the files).
To add the elasticsearch datasource, login to Grafana at `localhost:3000` and use the following:
- URL: `http://elasticsearch:9200`
- Skip TLS Verify: True
- Index name: `filebeat-*
- Time field name: `@timestamp`
- ElasticSearch version: `7.10+`

To add the database datasource use the following:
- Host: `db:5432`
- Database: `lega`
- User: `lega_in`
- Password: `lega_in`
- TLS/SSL Mode: `disable`

Save and test both datasources.

#### Add dashboards
Create a new dashboard for presenting the database information. One example could be to add a `table` in order to present the information of all files, using the following query:
```postgres
SELECT
  *
FROM
  local_ega.main
```

Create a new dashboard for presenting the elastic search information. One example could be to add a `histogram` in order to present the the number of logs per timestamp, 
or to filter for a specific level of logs using a query like:
```sh
message:*DEBUG*
```


