# sda-dashboard
Operator dashboard for controlling the NeIC Sensitive Data Archive

Detailed instructions for running the services can be found under the `dev_utils` folder.

## Python test server

One of the goals of the project is to be able to make requests from the Grafana dashboard towards the RabbitMQ and Postgres. Given the CORS issues with making requests straight to these services, a python test server is included in the project. To run the python server use
```sh
python test-server.py
```
The server currently contains an insert query to the database, therefore, it should be possible to call the server from Grafana and add files.

### Future work
Use different endpoints in the `test-server.py`, to allow for 
- sending RabbitMQ messages
- updating statuses in the database