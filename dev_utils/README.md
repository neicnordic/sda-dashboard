# Local testing howto

The docker compose contains the followin services:
- sda-db, sda-mq
- minio (as S3 backend instance)
- sda-pipeline
- logging (ELK stack and Grafana)
- bootstrap script

Notice that the db is using the newest version from [this pull request](https://github.com/neicnordic/sda-db/pull/56).
## Start the services
To start the services run
```sh
docker-compose up
```

### Sanity checks

#### Database
If everything worked as it is supposed, there should be a number of files in the database. To check that this is the case, connecting to the database with
```sh
docker exec -it db /bin/bash
```
Inside the container run
```sh
psql -U lega_in -h localhost -p 5432 lega
```
and run the following query, which should return 4 results
```sh
select * from local_ega.main;
```

#### Filebeat
Make sure that filebeat has started running
```sh
docker logs dev_utils-filebeat-1
```
In case filebeat doesn't start, it is possible that you need to change the owner and the permissions with
```sh
sudo chown root filebeat.yml
sudo chmod go-w filebeat.yml
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
Grafana gives the possibility to create different dashboards from different data sources. In this case, you can can create two dashboards in Grafana, one for the logs and one for the database. Login with `admin:rootpass` at `localhost:3000` and follow the instructions below to add the dashboards.

#### Import the dashboard examples
Under dashboard (four rectangles on the left menu), select `+ Import` and then click on `Upload JSON file` and select 
- first the `dev_utils/grafana-configs/database-dashboard.json` with the postgres datasource
- then the `dev_utils/grafana-configs/logs-dashboard.json` with the elasticsearch datasource.

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


