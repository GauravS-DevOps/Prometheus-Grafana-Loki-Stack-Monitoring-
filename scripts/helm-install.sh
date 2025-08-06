#!/bin/bash

# 🚀 Prometheus + Grafana + Loki Stack Installer

set -e

echo "🧱 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "📦 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Installing Kube Prometheus Stack..."
helm install kps prometheus-community/kube-prometheus-stack \
  --namespace monitoring

echo "📦 Installing Loki + Promtail..."
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true

echo "✅ Installation Complete."
echo "🔐 Fetch Grafana password with:"
echo "kubectl get secret --namespace monitoring kps-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode ; echo"

echo "🔗 Access Grafana by port-forwarding:"
echo "kubectl port-forward -n monitoring svc/kps-grafana 3000:80"
