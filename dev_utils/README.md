# Local testing howto

The docker compose contains the followin services:
- sda-db, sda-mq
- minion (as S3 backend instance)
- sda-pipeline
- logging (ELK stack and Grafana)
- bootstrapt script

## Start the services
To start the services run
```sh
docker-compose up
```
This should start all the containers mentioned above and run the bootstrap script, which ingests two different datasets.

### Logging in Kibana
The compose file contains elasticsearch, kibana and filebeat as part of the logging. The configuration of filebeat can be found in `filebeat.yml` file. In order to get the logs in kibana and grafana, go to kibana UI in a browser, at `localhost:5601` and create a new index under `Management`/`Index Patterns`. The name of the pattern should be `filebeat-*` and the Time Filter field name `@timestamp`. 

Under the `Discover` tab, you should be able to see the logs for all containers using an image that starts with `sda-`.

### Grafana configuration
Once the logs appear in Kibana, you can can create two dashboards in Grafana, one for the logs and one for the database.

#### Add sources
There are two different sources that can be added in the Grafana instance, the elastic search (containing the logs) and the database (containing information about the files).
To add the Elasticsearch datasource, login to Grafana at `localhost:3000` and use the following:
- URL: `http://elasticsearch:9200`
- Skip TLS Verify: True
- Index name: `filebeat-*
- Time field name: `@timestamp`
- ElasticSearch version: `7.10+`

To add the PostgreSQL datasource use the following:
- Host: `db:5432`
- Database: `lega`
- User: `lega_in`
- Password: `lega_in`
- TLS/SSL Mode: `disable`

Save and test both datasources.

#### Import the dashboard examples
Under dashboard (four rectangles on the left menu), select `+ Import` and then click on `Upload JSON file` and select 
- first the `dev_utils/grafana-dashboards/database-dashboard.json` with the postgres datasource
- then the `dev_utils/grafana-dashboards/logs-dashboard.json` with the elasticsearch datasource.

Then you should be able to see the two dashboards. They contain one panel each with very simple queries, as samples. Feel free to add more panels and/or dashboards to fit your needs.

#### Example dashboards
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
message:*DEBUG* AND container.labels.com_docker_compose_service: "verify"
```


