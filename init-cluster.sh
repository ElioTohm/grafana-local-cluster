#!/bin/bash
. $(pwd)/init.sh

print_headline "Create Cluster"
kind create cluster --name grafana --config kind.config --wait 5m

print_headline "Installing nginx ingress"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
print_header "waiting for installation to be complete"
kubectl wait pod -l app.kubernetes.io/component=controller,app.kubernetes.io/name=ingress-nginx --for=condition=Ready --namespace=ingress-nginx --timeout=300s
