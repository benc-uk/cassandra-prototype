# Cassandra Prototype

A prototype sample app investigating using Go, Quarkus, Cassandra, Helm, Prometheus & Grafana

## Makefile

- `build`
- `lint`
- `format`
- `test`
- `test-output`

## Deployment Automation - Helm Chart

Helm chart in `./kubernetes/helm/testapp` carries out the following:

- Deploys the Quarkus app from ghcr.io/benc-uk/java-cassandra-test
- Deploys Cassandra + keyspace & table
- Prometheus & Grafana
  - Prometheus set to scrape metrics exported by the app (See below)

## CI/CD - GitHub Actions

`./.github/workflows/ci-build.yml` - A very standard CI pipeline using GitHub Actions

- Runs Go format and linting
- Run unit tests and code coverage + JUnit reporting
- Builds the app as container and pushes to GitHub container registry

## Observability - Prometheus & Grafana

- The app exposes standard metrics using the [MicroProfile Metrics spec & Quarkus Plugin](https://quarkus.io/guides/microprofile-metrics)

- The app REST controller also exposes some custom app specific metrics, around the REST operation counts and timing.

- These metrics can be scraped by Prometheus.

- A Grafana dashboard `./kubernetes/helm/testapp/files/grafana-dashboard.json`, created via the generator in `./microprofile-grafana`. This is cloned from https://github.com/jamesfalkner/microprofile-grafana

## Load Testing

Using k6.io See `./testing/loadtest.js`

Run with:

```
export TEST_API_ENDPOINT=https://localhost:8080
export TEST_STAGE_TIME=10
k6 run loadtest.js
```

## Local Scripts

`./scripts/cassandra-local.sh` - Starts Cassandra locally in Docker and creates required keyspace and table
