#!/usr/bin/env bash
# CKAD Practice Test 01 - environment setup
# Idempotent: safe to re-run. Creates namespaces, contexts and seed resources.
set -euo pipefail

CLUSTER="kind-multi-node-cluster"
USERNAME="kind-multi-node-cluster"
NAMESPACES=(pluto neptune saturn mercury venus mars)

echo "==> Verifying cluster reachable"
kubectl --context "$CLUSTER" cluster-info >/dev/null

echo "==> Creating namespaces"
for ns in "${NAMESPACES[@]}"; do
  kubectl --context "$CLUSTER" create namespace "$ns" --dry-run=client -o yaml | kubectl --context "$CLUSTER" apply -f - >/dev/null
done

echo "==> Creating contexts (one per namespace)"
for ns in "${NAMESPACES[@]}"; do
  kubectl config set-context "ckad-$ns" \
    --cluster="$CLUSTER" --user="$USERNAME" --namespace="$ns" >/dev/null
done

echo "==> Creating answer-file directory /tmp/ckad"
mkdir -p /tmp/ckad

echo "==> Seeding pluto (Q2: intentionally broken ReplicaSet)"
kubectl --context "$CLUSTER" apply -f - >/dev/null <<'EOF'
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
  namespace: pluto
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25-this-tag-does-not-exist
        ports:
        - containerPort: 80
EOF

echo "==> Seeding neptune (Q7/Q8: label-selector fodder)"
for spec in \
  "np-1 prod web" \
  "np-2 prod cache" \
  "np-3 prod db" \
  "np-4 dev web" \
  "np-5 dev cache" \
  "np-6 qa web"; do
  set -- $spec
  kubectl --context "$CLUSTER" apply -f - >/dev/null <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $1
  namespace: neptune
  labels:
    env: $2
    tier: $3
spec:
  containers:
  - name: c
    image: registry.k8s.io/pause:3.9
EOF
done

echo "==> Seeding venus (Q18: pod that must be recreated without a token)"
kubectl --context "$CLUSTER" apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: no-token
  namespace: venus
spec:
  containers:
  - name: c
    image: registry.k8s.io/pause:3.9
EOF

echo "==> Waiting for seed pods to settle"
kubectl --context "$CLUSTER" wait --for=condition=Ready pod -n neptune --all --timeout=90s >/dev/null 2>&1 || true

kubectl config use-context "$CLUSTER" >/dev/null

cat <<'BANNER'

=========================================================
  CKAD Practice Test 01 is ready.
=========================================================
  Questions : ckad-practice-01/questions.md
  Grade     : ./ckad-practice-01/grade.sh
  Reset     : ./ckad-practice-01/cleanup.sh && ./ckad-practice-01/setup.sh

  Contexts created:
    ckad-pluto  ckad-neptune  ckad-saturn
    ckad-mercury  ckad-venus  ckad-mars

  Suggested time limit: 60 minutes.
=========================================================
BANNER
