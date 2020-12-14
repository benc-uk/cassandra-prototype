# Cassandra Prototype

A prototype sample app investigating using Go, Cassandra, Helm, Prometheus & Grafana

The app is written in Go and heavily based on a previous project (dapr-store). The main source is in `cmd`.  
It has a distinct MVC style separation between the HTTP API layer (`routes.go`) and the service layer. The service is defined as both a interface spec (package `spec`), with a concrete implementation backed by Cassandra (package `impl`) and also a mock implementation for unit testing without at DB required.

The `pkg` tree of the repo contains supporting packages providing; API base services (for status and health checking), API testing and a standard problem package used by everything in order to return standard RFC-7807 format errors.

This cmd and pkg structure, follows the [golang-standards/project-layout](https://github.com/golang-standards/project-layout)

## Local Quick Start

Ensure you have Docker running locally

```bash
cd scripts
./cassandra-local.sh
cd ../cmd
./run.sh
```

## API Operations and Routes

See this API test file ([testing/api-test.rest](testing/api-test.rest)) for example requests and payloads (You will need the VS Code REST extension)

```bash
GET /api/orders         - Return all orders
GET /api/orders/{id}    - Get a single order
DELETE /api/orders/{id} - Delete a single order
POST /api/orders        - Create a new order
```

## Application config

- `CASSANDRA_CLUSTER` - Hostname or IP to connect to the Cassandra cluster (default: 'localhost').
- `CASSANDRA_KEYSPACE` - Cassandra keyspace to use (default: 'k1').
- `CASSANDRA_USERNAME` - Optional. Username to connect to Cassandra with.
- `CASSANDRA_PASSWORD` - Optional. Password for above user.
- `PORT` - Port to listen on, (default: '8080')

## Repo Structure

```
📂 .github/workflows   - GitHub Actions
📂 cmd                 - Go REST app
📂 kubernetes/helm     - Helm charts
  📂 cassandra-go-api  - Helm chart for app + Cassandra DB
  📂 prom-grafana      - Helm chart for Prometheus + Grafana
📂 old-java            - Junk
📂 pkg                 - Supporting packages for Go app
📂 scripts             - Local scripts, mainly for Cassandra
📂 testing             - Testing & load testing
  📂 api               - API tests, Postman etc
  📂 load              - Load testing with k6
```

## Project Makefile

- `make build` - Build docker image for Go app
- `make push` - Push to registry
- `lint` - Run linting checks
- `format` - Run code format checks (will error if any found)
- `test` - Run unit tests
- `test-output` - Run unit tests with output files (JUnit and code coverage)
- `reports` - Create HTML report from test-output

You may want to set `DOCKER_REG`, `DOCKER_REPO` and `DOCKER_TAG` before running `make build`  
Also `VERSION` and `BUILD_INFO` can be set for versioning

## Deployment Automation - Helm Chart

Helm chart in `./kubernetes/helm/testapp` carries out the following:

- Deploys the Go app from `ghcr.io/benc-uk/cassandra-prototype`
- Deploys Cassandra + keyspace & table
- Prometheus & Grafana
  - Prometheus set to scrape metrics exported by the app (See below)

[See values file for full details](kubernetes/helm/testapp/values.yaml) of how to configure this chart

## Load Testing

Currently k6.io load testing framework is being investigated and used.  
There is a single load test script: `./testing/loadtest.js`

This load tests the REST API of the app with GET, POST & DELETE operations, and ramps to 120 users and checks the results of the API operations for success, and a threshold of 90th percentile of http_req_duration is less than 900 millseconds

The env vars `TEST_API_ENDPOINT` and `TEST_STAGE_TIME` can be set to configure which API endpoint the load test runs against and how long each stage of the virtual user ramp up is (default is 20 seconds, for quick tests can be dropped down to 1 or 2 seconds)

### Run Locally

Install k6 (it's a standalone binary) using this script https://github.com/benc-uk/tools-install/blob/master/k6.sh

Then run:

```bash
cd testing
export TEST_API_ENDPOINT=https://localhost:8080
export TEST_STAGE_TIME=10
k6 run loadtest.js
```

### Run In Azure + InfluxDB + Grafana

A bash script is provided which runs the load test from Azure and also collects the results in an InfluxDB database and sets up Grafana for reporting and visualization.

Everything is run in Azure Container Instances and expects the API endpoint to be publicly accessible.

You will **_definitely_** want to change the variables at the top of the file before running, as there are so many parameters they have been left hard coded into the script for the time being. The InfluxDB + Grafana container instances are configured by the `influx-grafana.yaml` file (this is dynamically injected using envsubst)

```bash
cd testing
./run-azure.sh
```

The script will output the URL to access Grafana, and the default username & password is admin/admin

To add a dashboard in Grafana to see the results, [several pre-configured dashboards exist](https://k6.io/docs/results-visualization/influxdb-+-grafana#preconfigured-grafana-dashboards), simply login to Grafana and import them using the ID.

## CI/CD - GitHub Actions

[ci-build.yml](.github/workflows/ci-build.yml) - A very standard CI pipeline using GitHub Actions

- Runs Go format and linting
- Run unit tests and code coverage + JUnit reporting
- Builds the app as container and pushes to GitHub container registry

## Observability - Prometheus & Grafana

📝 Todo - since switching to Go need to add metrics back into the app which we got for free with Quarkus

## Local Scripts

- [cassandra-local.sh](./scripts/cassandra-local.sh) - Starts Cassandra locally in Docker and creates required keyspace and orders table
