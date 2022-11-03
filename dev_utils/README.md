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
Make sure that filebeat has started running
```sh
docker logs dev_utils-filebeat-1
```
In case filebeat doesn't start, it is possible that you need to change the owner and the permissions with
```sh
sudo chown root filebeat.yaml
sudo chmod go-w filebeat.yaml
```
This should start all the containers mentioned above and run the bootstrap script, which ingests two different datasets. Keep in mind that starting the services can take some time. You can follow the progress of the bootstrap script using
```sh
docker logs bs -f
```
Note: The bootstrap container takes some time to start, since it is waiting for `mq` and `db` to initiate and become healthy.


### Logs in Kibana
The compose file contains elasticsearch, kibana and filebeat as part of the logging. The configuration of filebeat can be found in `filebeat.yml` file. In order to get the logs in kibana, go to kibana UI in a browser, at `localhost:5601` and create a new index pattern under `Stack Management`/`Index Patterns`. The name of the pattern should be `filebeat-*` and the Time Filter field name `@timestamp`. 

Under the `Discover` tab, you should be able to see the logs for all containers using an image that starts with `sda-`.

### Grafana configuration
Grafana gives the possibility to create different dashboards from different data sources. In this case, you can can create two dashboards in Grafana, one for the logs and one for the database. Login with `admin:admin` at `localhost:3000` and follow the instructions below to add the dashboards.

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


