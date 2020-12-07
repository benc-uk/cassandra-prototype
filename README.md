# Java Quarkus + Cassandra Prototype

A prototype sample app investigating using Java, Quarkus, Cassandra, Helm, Prometheus & Grafana

This repo has been initially created using the app generator https://code.quarkus.io/

The steps in this guide https://quarkus.io/guides/cassandra have been partially applied, resulting in the code in `./src/main/java/org/microsoft/fruit` and a functioning app with a basic REST API and Cassandra datastore

# Additions

## Deployment Automation - Helm Chart

Helm chart in `./kubernetes/helm/testapp` carries out the following:

- Deploys the Quarkus app from ghcr.io/benc-uk/java-cassandra-test
- Deploys Cassandra + keyspace & table
- Prometheus & Grafana
  - Prometheus set to scrape metrics exported by the app (See below)
  - Grafana configured wth datasource & application specific dashboard (see below)

## CI/CD - GitHub Actions

`./.github/workflows/ci.yml` - A very simple CI pipeline using GitHub Actions which builds the app and pushes it to GitHub Container Registry

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

# Quarkus Details

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:

```shell script
./mvnw compile quarkus:dev
```

## Packaging and running the application

The application can be packaged using:

```shell script
./mvnw package
```

It produces the `quarkus-test-1.0.0-SNAPSHOT-runner.jar` file in the `/target` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/lib` directory.

If you want to build an _über-jar_, execute the following command:

```shell script
./mvnw package -Dquarkus.package.type=uber-jar
```

The application is now runnable using `java -jar target/quarkus-test-1.0.0-SNAPSHOT-runner.jar`.

## Creating a native executable

You can create a native executable using:

```shell script
./mvnw package -Pnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using:

```shell script
./mvnw package -Pnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/quarkus-test-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult https://quarkus.io/guides/maven-tooling.html.
