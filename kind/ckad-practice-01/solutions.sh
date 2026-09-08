#!/usr/bin/env bash
# CKAD Practice Test 01 - ANSWER KEY.  *** SPOILER *** Do not run before attempting.
# Also serves as the grader's self-test: running this should yield 100/100.
set -uo pipefail
mkdir -p /tmp/ckad

echo "### Q1"
kubectl config use-context ckad-pluto >/dev/null
kubectl run nginx-solo --image=nginx:1.25 --dry-run=client -o yaml > /tmp/ckad/q1.yaml
kubectl apply -f /tmp/ckad/q1.yaml

echo "### Q2"
kubectl set image rs/web-rs web=nginx:1.25
kubectl delete pod -l app=web --wait=false          # RS recreates with the fixed image
kubectl scale rs web-rs --replicas=5

echo "### Q3"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ReplicationController
metadata:
  name: legacy-rc
  namespace: pluto
spec:
  replicas: 2
  selector:
    app: legacy
  template:
    metadata:
      labels:
        app: legacy
    spec:
      containers:
      - name: httpd
        image: httpd:2.4
EOF

echo "### Q4"
kubectl config use-context ckad-neptune >/dev/null
kubectl create deployment api-gw --image=nginx:1.24 --replicas=4
kubectl rollout status deploy/api-gw --timeout=180s

echo "### Q5"
kubectl set image deploy/api-gw nginx=nginx:1.25
kubectl rollout status deploy/api-gw --timeout=180s
kubectl rollout undo deploy/api-gw
kubectl rollout status deploy/api-gw --timeout=180s
kubectl get deploy api-gw -o jsonpath='{.spec.template.spec.containers[0].image}' > /tmp/ckad/q5.txt

echo "### Q6"
kubectl patch deploy api-gw -p \
  '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":2,"maxUnavailable":0}}}}'

echo "### Q7"
kubectl get pods -l 'env=prod,tier!=cache' -o name | cut -d/ -f2 > /tmp/ckad/q7.txt

echo "### Q8"
kubectl label pods -l env=dev team=alpha --overwrite

echo "### Q9"
kubectl expose deployment api-gw --name=api-gw-svc --port=80 --target-port=80 --type=ClusterIP

echo "### Q10"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-np
  namespace: neptune
spec:
  type: NodePort
  selector:
    env: prod
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30081
EOF

echo "### Q11"
echo "api-gw-svc.neptune.svc.cluster.local" > /tmp/ckad/q11.txt

echo "### Q12"
kubectl config use-context ckad-saturn >/dev/null
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-1
  namespace: saturn
spec:
  securityContext:
    runAsUser: 1010
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF

echo "### Q13"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-2
  namespace: saturn
spec:
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]
        drop: ["CHOWN"]
EOF

echo "### Q14"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: resource-1
  namespace: saturn
spec:
  containers:
  - name: c
    image: nginx:1.25
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
EOF

echo "### Q15"
kubectl config use-context ckad-mercury >/dev/null
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-mem-defaults
  namespace: mercury
spec:
  limits:
  - type: Container
    default:
      cpu: 300m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 256Mi
    max:
      cpu: "1"
    min:
      cpu: 50m
EOF
kubectl run lr-test --image=nginx:1.25

echo "### Q16"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mercury-quota
  namespace: mercury
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
EOF

echo "### Q17"
kubectl config use-context ckad-venus >/dev/null
kubectl create serviceaccount pipeline-sa
kubectl create deployment builder --image=nginx:1.25
kubectl set serviceaccount deployment builder pipeline-sa
kubectl create token pipeline-sa > /tmp/ckad/q17.txt

echo "### Q18"
kubectl delete pod no-token --now
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: no-token
  namespace: venus
spec:
  automountServiceAccountToken: false
  containers:
  - name: c
    image: registry.k8s.io/pause:3.9
EOF

echo "### Q19"
kubectl config use-context ckad-mars >/dev/null
kubectl taint node multi-node-cluster-worker4 workload=batch:NoSchedule --overwrite
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: batch-1
  namespace: mars
spec:
  nodeSelector:
    kubernetes.io/hostname: multi-node-cluster-worker4
  tolerations:
  - key: workload
    operator: Equal
    value: batch
    effect: NoSchedule
  containers:
  - name: c
    image: nginx:1.25
EOF

echo "### Q20"
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: edge-pod
  namespace: mars
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - red
            - blue
  tolerations:
  - key: color
    operator: Equal
    value: red
    effect: NoSchedule
  - key: color
    operator: Equal
    value: blue
    effect: NoSchedule
  containers:
  - name: c
    image: nginx:1.25
EOF

kubectl config use-context kind-multi-node-cluster >/dev/null
echo "### done - waiting for pods to settle"
for ns in pluto neptune saturn mercury venus mars; do
  kubectl -n "$ns" wait --for=condition=Ready pod --all --timeout=180s >/dev/null 2>&1 || true
done
