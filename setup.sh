#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="k8s-testing"
DEPLOYMENT="echo-app"
SERVICE="echo-service"

echo "Resetting namespace ${NAMESPACE}..."
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true --wait=true >/dev/null 2>&1 || true

echo "Ensuring cluster nodes can schedule workloads..."
for taint_key in node-role.kubernetes.io/master node-role.kubernetes.io/control-plane; do
  kubectl taint nodes --all "${taint_key}-" >/dev/null 2>&1 || true
done

kubectl create namespace "${NAMESPACE}" >/dev/null

echo "Creating demo deployment and service..."
kubectl apply -n "${NAMESPACE}" -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: echo-app
  template:
    metadata:
      labels:
        app: echo-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: echo-app
              topologyKey: kubernetes.io/hostname
      containers:
      - name: echo
        image: hashicorp/http-echo:1.0.0
        args:
        - "-text=hello-from-pod"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: echo-service
spec:
  selector:
    app: echo-app
  ports:
  - name: http
    port: 80
    targetPort: 5678
EOF

echo "Waiting for deployment to become available..."
kubectl rollout status deployment/"${DEPLOYMENT}" -n "${NAMESPACE}" --timeout=180s >/dev/null

echo "Waiting for service endpoints..."
for _ in $(seq 1 60); do
  endpoint_ips="$(kubectl get endpoints "${SERVICE}" -n "${NAMESPACE}" -o jsonpath='{.subsets[*].addresses[*].ip}' || true)"
  if [ -n "${endpoint_ips}" ]; then
    break
  fi
  sleep 1
done

endpoint_ips="$(kubectl get endpoints "${SERVICE}" -n "${NAMESPACE}" -o jsonpath='{.subsets[*].addresses[*].ip}' || true)"
if [ -z "${endpoint_ips}" ]; then
  echo "Setup failed: service endpoints were not created." >&2
  exit 1
fi

echo "Testing cluster is ready."
echo "Namespace: ${NAMESPACE}"
echo "Deployment: ${DEPLOYMENT}"
echo "Service: ${SERVICE}"
echo "Pods:"
kubectl get pods -n "${NAMESPACE}"
echo "Nodes:"
kubectl get nodes -o wide
