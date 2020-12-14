#helm repo add influxdata https://helm.influxdata.com/

helm install app ./cassandra-go-api -f app-values.yaml
helm install pg ./prom-grafana -f prom-values.yaml
helm install influx influxdata/influxdb -f ./influxdb-values.yaml
