#!/bin/bash
. $(pwd)/init.sh

print_headline "Installing Grafana Stack"

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

print_headline "installing mimir"
helm upgrade --install --atomic mimir grafana/mimir-distributed --create-namespace -n mimir

print_headline "installing Loki"
helm upgrade --install --atomic loki grafana/loki --create-namespace -n loki -f loki-values.yaml

print_headline "installing tempo"
helm upgrade --install --atomic tempo grafana/tempo-distributed --create-namespace -n tempo -f tempo-values.yaml

print_headline "install kube-state-metrics"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install --atomic kube-state-metrics prometheus-community/kube-state-metrics --create-namespace -n kube-state-metrics

#print_headline "install OpenCost"
#helm repo add opencost https://opencost.github.io/opencost-helm-chart
#helm repo update
#helm upgrade --install opencost opencost/opencost -n alloy --create-namespace

print_headline "install Grafana Alloy"
helm upgrade --install --atomic alloy grafana/k8s-monitoring -n alloy --create-namespace -f k8s-monitoring.yaml --wait

print_headline "installing dashboard"
helm upgrade --install --atomic grafana-dashboard grafana/grafana --create-namespace -n monitoring -f grafana-dashboard-values.yaml --wait
kubectl apply -f grafana-dashboard-vs.yaml
print_header "admin password: $(kubectl get secret --namespace monitoring grafana-dashboard -o jsonpath="{.data.admin-password}" | base64 --decode)"

helm upgrade --install meta-monitoring grafana/meta-monitoring --create-namespace -n meta -f meta-monitoring-values.yaml
# dashboard to add 17605 17606 17607 17608 17609 16026
