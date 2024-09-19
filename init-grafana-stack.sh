#!/bin/bash
. $(pwd)/init.sh

print_headline "Installing Grafana Stack"

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

print_headline "installing mimir"
helm upgrade --install --atomic mimir grafana/mimir-distributed --create-namespace -n mimir

print_headline "installing Loki"
helm upgrade --install --atomic loki grafana/loki --create-namespace -n loki -f loki-values.yaml

print_headline "install kube-state-metrics"
helm upgrade --install --atomic kube-state-metrics prometheus-community/kube-state-metrics --create-namespace -n kube-state-metrics

print_headline "install Grafana Alloy"
helm upgrade --install --atomic alloy grafana/k8s-monitoring -n alloy --create-namespace -f k8s-monitoring.yaml --wait

print_headline "installing Redis and Postgress for scalability"
helm upgrade --install --create-namespace -n grafana postgresql-ha bitnami/postgresql-ha --wait
helm upgrade --install --create-namespace -n grafana redis-cluster bitnami/redis-cluster --wait

print_headline "installing dashboard"
helm upgrade --install --atomic grafana-dashboard grafana/grafana --create-namespace -n grafana -f grafana-dashboard-values.yaml --wait
helm upgrade --install meta-monitoring grafana/meta-monitoring --create-namespace -n meta -f meta-monitoring-values.yaml
print_header "admin password: $(kubectl get secret --namespace grafana grafana-dashboard -o jsonpath="{.data.admin-password}" | base64 --decode)"
