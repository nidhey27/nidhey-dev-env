#!/usr/bin/env bash
# CKAD Practice Test 01 - teardown. Leaves your original color-node practice intact.
set -uo pipefail

K="kubectl --context kind-multi-node-cluster"

echo "==> Deleting practice namespaces"
$K delete namespace pluto neptune saturn mercury venus mars --ignore-not-found --wait=false

echo "==> Reverting node changes made during the test"
$K taint node multi-node-cluster-worker4 workload- 2>/dev/null || true
$K label node multi-node-cluster-worker5 disk- 2>/dev/null || true

echo "==> Removing contexts"
for ns in pluto neptune saturn mercury venus mars; do
  kubectl config delete-context "ckad-$ns" >/dev/null 2>&1 || true
done
kubectl config use-context kind-multi-node-cluster >/dev/null

echo "==> Removing answer files"
rm -rf /tmp/ckad

echo "Done. Namespaces are terminating in the background."
