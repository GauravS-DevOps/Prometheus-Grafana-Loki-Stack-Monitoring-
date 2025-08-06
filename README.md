########################################################
# 📈 Full Monitoring Stack with Prometheus + Grafana + Loki
# ------------------------------------------------------
# This guide walks you through setting up a full observability stack 
# on Kubernetes using Helm in the simplest and most reliable way.
#
# 👇 Components you'll install:
# - Prometheus (metrics)
# - Grafana (visualization)
# - Loki (logs)
# - Promtail (log shipper)
# - Alertmanager, Node Exporter, Kube-State-Metrics (via KPS)
#
# 💡 Even if you're new to K8s or Helm — follow along step by step.
########################################################


# 🔧 STEP 1: Add Helm Repositories
# -------------------------------------
# These Helm repositories contain the official charts for Prometheus and Loki.
# You only need to add them once per machine.

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update


# 📦 STEP 2: Install the Kube-Prometheus-Stack (KPS)
# ---------------------------------------------------
# This is the core monitoring stack. It installs Prometheus, Grafana, Alertmanager, 
# Node Exporter, Kube-State-Metrics, and loads default dashboards and alerts.
# We'll install everything in a new namespace called "monitoring".

helm install kps prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace


# 🔍 STEP 3: Verify Installation
# ------------------------------
# After a few seconds, check if the pods and services are running correctly.

kubectl get pods -n monitoring
kubectl get svc -n monitoring

# You should see pods for Prometheus, Grafana, Alertmanager, and exporters.
# All should be in "Running" or "Completed" state.


# 📦 STEP 4: Install Loki and Promtail
# ------------------------------------
# Loki is your log storage engine. Promtail will ship logs from all pods to Loki.
# We'll disable Grafana in this chart since it’s already installed with KPS.

helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true

# Wait for a few seconds and check:

kubectl get pods -n monitoring | grep loki


# 🔐 STEP 5: Access Grafana Dashboard
# ------------------------------------
# KPS installs Grafana, but we need to:
# - Decode the default admin password
# - Port forward the Grafana service to access the UI in browser

# 1️⃣ Get Grafana admin password:
kubectl get secret --namespace monitoring kps-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# 2️⃣ Port-forward Grafana to your local machine:
kubectl port-forward -n monitoring svc/kps-grafana 3000:80

# 3️⃣ Open your browser and go to:
# http://localhost:3000

# ➡️ Login with:
# Username: admin
# Password: <decoded password from step 1>


# 🔗 STEP 6: Connect Loki to Grafana as a Data Source
# ----------------------------------------------------
# Once inside Grafana UI:
# - Go to ⚙️  (Gear icon) → Data Sources → Add Data Source
# - Choose “Loki” as the type
# - Enter this URL:

#   http://loki.monitoring.svc.cluster.local:3100

# - Click “Save & Test”
# If successful, you’ll be able to query logs via Explore tab.


# 🎨 STEP 7: Visualize Metrics & Logs
# ------------------------------------
# Grafana comes preloaded with dashboards from KPS.
# For logs:
# - Go to the 🔎 “Explore” tab
# - Select “Loki” as the data source
# - Start typing queries like `{job="kubernetes-pods"}`

# For more visual dashboards:
# - Go to the “Dashboards” section
# - Use built-in ones like:
#   - Kubernetes / Nodes
#   - Cluster / API Server
#   - Pod / Workload resources


# 🎯 DONE!
# ---------------------------------------------------
# You now have:
# ✅ Metrics via Prometheus
# ✅ Logs via Loki
# ✅ Dashboards via Grafana
# ✅ Alerts via Alertmanager

# 🚀 Happy Monitoring!
