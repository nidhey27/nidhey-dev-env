#!/usr/bin/env bash
# CKAD Practice Test 01 - auto grader
K="kubectl --context kind-multi-node-cluster"
G=$'\033[0;32m'; R=$'\033[0;31m'; Y=$'\033[0;33m'; B=$'\033[1m'; N=$'\033[0m'

SCORE=0; MAX=0; Q_SCORE=0; Q_MAX=0; QN=""
declare -a REPORT

chk() { # chk <points> <description> <shell expression>
  local pts=$1 desc=$2 expr=$3
  Q_MAX=$((Q_MAX+pts)); MAX=$((MAX+pts))
  if eval "$expr" >/dev/null 2>&1; then
    SCORE=$((SCORE+pts)); Q_SCORE=$((Q_SCORE+pts))
    printf "    ${G}PASS${N}  %-56s ${G}+%s${N}\n" "$desc" "$pts"
  else
    printf "    ${R}FAIL${N}  %-56s ${R}0/%s${N}\n" "$desc" "$pts"
  fi
}

q() { # start a new question
  [ -n "$QN" ] && REPORT+=("$QN|$Q_SCORE|$Q_MAX")
  QN="$1"; Q_SCORE=0; Q_MAX=0
  printf "\n${B}%s${N} %s\n" "$1" "$2"
}

finish() { [ -n "$QN" ] && REPORT+=("$QN|$Q_SCORE|$Q_MAX"); }

printf "${B}=========================================================${N}\n"
printf "${B}  CKAD Practice Test 01 - Results${N}\n"
printf "${B}=========================================================${N}\n"

# ---------- Section A ----------
q Q1 "Imperative generation"
chk 1 "/tmp/ckad/q1.yaml exists" 'test -s /tmp/ckad/q1.yaml'
chk 1 "manifest declares pod nginx-solo with nginx:1.25" \
  'grep -q "nginx-solo" /tmp/ckad/q1.yaml && grep -q "nginx:1.25" /tmp/ckad/q1.yaml'
chk 2 "pod nginx-solo running in pluto with nginx:1.25" \
  '[ "$('"$K"' -n pluto get pod nginx-solo -o jsonpath="{.spec.containers[0].image}")" = "nginx:1.25" ] &&
   [ "$('"$K"' -n pluto get pod nginx-solo -o jsonpath="{.status.phase}")" = "Running" ]'

q Q2 "Repair broken ReplicaSet"
chk 2 "web-rs image fixed to nginx:1.25" \
  '[ "$('"$K"' -n pluto get rs web-rs -o jsonpath="{.spec.template.spec.containers[0].image}")" = "nginx:1.25" ]'
chk 2 "web-rs desired replicas = 5" \
  '[ "$('"$K"' -n pluto get rs web-rs -o jsonpath="{.spec.replicas}")" = "5" ]'
chk 2 "web-rs has 5 ready replicas" \
  '[ "$('"$K"' -n pluto get rs web-rs -o jsonpath="{.status.readyReplicas}")" = "5" ]'

q Q3 "ReplicationController"
chk 2 "ReplicationController legacy-rc exists in pluto" "$K -n pluto get rc legacy-rc"
chk 1 "replicas = 2" '[ "$('"$K"' -n pluto get rc legacy-rc -o jsonpath="{.spec.replicas}")" = "2" ]'
chk 1 "image = httpd:2.4" \
  '[ "$('"$K"' -n pluto get rc legacy-rc -o jsonpath="{.spec.template.spec.containers[0].image}")" = "httpd:2.4" ]'
chk 1 "template label app=legacy" \
  '[ "$('"$K"' -n pluto get rc legacy-rc -o jsonpath="{.spec.template.metadata.labels.app}")" = "legacy" ]'

# ---------- Section B ----------
q Q4 "Create Deployment"
chk 2 "deployment api-gw exists in neptune" "$K -n neptune get deploy api-gw"
chk 1 "replicas = 4" '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.spec.replicas}")" = "4" ]'
chk 1 "4 replicas available" '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.status.availableReplicas}")" = "4" ]'

q Q5 "Rolling update and rollback"
chk 3 "deployment reached revision 3+ (update then undo)" \
  '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.metadata.annotations.deployment\.kubernetes\.io/revision}")" -ge 3 ]'
chk 2 "image rolled back to nginx:1.24" \
  '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.spec.template.spec.containers[0].image}")" = "nginx:1.24" ]'
chk 2 "/tmp/ckad/q5.txt records nginx:1.24" 'grep -q "nginx:1.24" /tmp/ckad/q5.txt'

q Q6 "Update strategy"
chk 3 "maxSurge = 2" \
  '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.spec.strategy.rollingUpdate.maxSurge}")" = "2" ]'
chk 2 "maxUnavailable = 0" \
  '[ "$('"$K"' -n neptune get deploy api-gw -o jsonpath="{.spec.strategy.rollingUpdate.maxUnavailable}")" = "0" ]'

q Q7 "Query with selectors"
chk 4 "q7.txt lists exactly np-1 and np-3" \
  '[ "$(tr -d " \r" < /tmp/ckad/q7.txt | grep -v "^$" | sort -u | tr "\n" ",")" = "np-1,np-3," ]'

q Q8 "Bulk labelling"
chk 4 "exactly np-4 and np-5 carry team=alpha" \
  '[ "$('"$K"' -n neptune get pods -l team=alpha -o name | sort | tr "\n" ",")" = "pod/np-4,pod/np-5," ]'

# ---------- Section C ----------
q Q9 "ClusterIP Service"
chk 1 "service api-gw-svc is ClusterIP" \
  '[ "$('"$K"' -n neptune get svc api-gw-svc -o jsonpath="{.spec.type}")" = "ClusterIP" ]'
chk 1 "port = 80" '[ "$('"$K"' -n neptune get svc api-gw-svc -o jsonpath="{.spec.ports[0].port}")" = "80" ]'
chk 1 "targetPort = 80" \
  '[ "$('"$K"' -n neptune get svc api-gw-svc -o jsonpath="{.spec.ports[0].targetPort}")" = "80" ]'
chk 2 "service has live endpoints (selector actually matches)" \
  '[ -n "$('"$K"' -n neptune get endpoints api-gw-svc -o jsonpath="{.subsets[0].addresses[0].ip}")" ]'

q Q10 "NodePort Service"
chk 1 "service web-np is NodePort" \
  '[ "$('"$K"' -n neptune get svc web-np -o jsonpath="{.spec.type}")" = "NodePort" ]'
chk 2 "nodePort = 30081" \
  '[ "$('"$K"' -n neptune get svc web-np -o jsonpath="{.spec.ports[0].nodePort}")" = "30081" ]'
chk 1 "selector is env=prod" \
  '[ "$('"$K"' -n neptune get svc web-np -o jsonpath="{.spec.selector.env}")" = "prod" ]'
chk 1 "port and targetPort are 80" \
  '[ "$('"$K"' -n neptune get svc web-np -o jsonpath="{.spec.ports[0].port}")" = "80" ] &&
   [ "$('"$K"' -n neptune get svc web-np -o jsonpath="{.spec.ports[0].targetPort}")" = "80" ]'

q Q11 "Service DNS"
chk 3 "q11.txt = api-gw-svc.neptune.svc.cluster.local" \
  'grep -qx "api-gw-svc.neptune.svc.cluster.local" /tmp/ckad/q11.txt'

# ---------- Section D ----------
q Q12 "runAsUser"
chk 1 "pod secure-1 exists in saturn" "$K -n saturn get pod secure-1"
chk 1 "image busybox:1.36" \
  '[ "$('"$K"' -n saturn get pod secure-1 -o jsonpath="{.spec.containers[0].image}")" = "busybox:1.36" ]'
chk 2 "pod-level securityContext.runAsUser = 1010" \
  '[ "$('"$K"' -n saturn get pod secure-1 -o jsonpath="{.spec.securityContext.runAsUser}")" = "1010" ]'
chk 1 "pod is Running" \
  '[ "$('"$K"' -n saturn get pod secure-1 -o jsonpath="{.status.phase}")" = "Running" ]'

q Q13 "Capabilities"
chk 1 "pod secure-2 exists in saturn" "$K -n saturn get pod secure-2"
chk 2 "container adds NET_ADMIN and SYS_TIME" \
  "$K -n saturn get pod secure-2 -o json | jq -e '.spec.containers[0].securityContext.capabilities.add | (index(\"NET_ADMIN\") != null and index(\"SYS_TIME\") != null)'"
chk 1 "container drops CHOWN" \
  "$K -n saturn get pod secure-2 -o json | jq -e '.spec.containers[0].securityContext.capabilities.drop | index(\"CHOWN\") != null'"
chk 1 "pod is Running" \
  '[ "$('"$K"' -n saturn get pod secure-2 -o jsonpath="{.status.phase}")" = "Running" ]'

# ---------- Section E ----------
q Q14 "Requests and limits"
chk 1 "requests.cpu = 100m" \
  '[ "$('"$K"' -n saturn get pod resource-1 -o jsonpath="{.spec.containers[0].resources.requests.cpu}")" = "100m" ]'
chk 1 "requests.memory = 256Mi" \
  '[ "$('"$K"' -n saturn get pod resource-1 -o jsonpath="{.spec.containers[0].resources.requests.memory}")" = "256Mi" ]'
chk 1 "limits.cpu = 500m" \
  '[ "$('"$K"' -n saturn get pod resource-1 -o jsonpath="{.spec.containers[0].resources.limits.cpu}")" = "500m" ]'
chk 1 "limits.memory = 512Mi" \
  '[ "$('"$K"' -n saturn get pod resource-1 -o jsonpath="{.spec.containers[0].resources.limits.memory}")" = "512Mi" ]'
chk 1 "pod is Running" \
  '[ "$('"$K"' -n saturn get pod resource-1 -o jsonpath="{.status.phase}")" = "Running" ]'

q Q15 "LimitRange"
chk 2 "default limits cpu=300m memory=512Mi" \
  "$K -n mercury get limitrange cpu-mem-defaults -o json | jq -e '.spec.limits[] | select(.type==\"Container\") | select(.default.cpu==\"300m\" and .default.memory==\"512Mi\")'"
chk 2 "defaultRequest cpu=100m memory=256Mi" \
  "$K -n mercury get limitrange cpu-mem-defaults -o json | jq -e '.spec.limits[] | select(.type==\"Container\") | select(.defaultRequest.cpu==\"100m\" and .defaultRequest.memory==\"256Mi\")'"
chk 1 "max cpu=1 and min cpu=50m" \
  "$K -n mercury get limitrange cpu-mem-defaults -o json | jq -e '.spec.limits[] | select(.type==\"Container\") | select(.max.cpu==\"1\" and .min.cpu==\"50m\")'"
chk 1 "pod lr-test inherited the defaults" \
  '[ "$('"$K"' -n mercury get pod lr-test -o jsonpath="{.spec.containers[0].resources.requests.cpu}")" = "100m" ] &&
   [ "$('"$K"' -n mercury get pod lr-test -o jsonpath="{.spec.containers[0].resources.limits.memory}")" = "512Mi" ]'

q Q16 "ResourceQuota"
chk 1 "requests.cpu = 2" \
  '[ "$('"$K"' -n mercury get quota mercury-quota -o jsonpath="{.spec.hard.requests\.cpu}")" = "2" ]'
chk 1 "requests.memory = 2Gi" \
  '[ "$('"$K"' -n mercury get quota mercury-quota -o jsonpath="{.spec.hard.requests\.memory}")" = "2Gi" ]'
chk 1 "limits.cpu = 4" \
  '[ "$('"$K"' -n mercury get quota mercury-quota -o jsonpath="{.spec.hard.limits\.cpu}")" = "4" ]'
chk 1 "limits.memory = 4Gi" \
  '[ "$('"$K"' -n mercury get quota mercury-quota -o jsonpath="{.spec.hard.limits\.memory}")" = "4Gi" ]'
chk 1 "pods = 10" \
  '[ "$('"$K"' -n mercury get quota mercury-quota -o jsonpath="{.spec.hard.pods}")" = "10" ]'

# ---------- Section F ----------
q Q17 "ServiceAccount"
chk 2 "serviceaccount pipeline-sa exists in venus" "$K -n venus get sa pipeline-sa"
chk 2 "deployment builder runs as pipeline-sa" \
  '[ "$('"$K"' -n venus get deploy builder -o jsonpath="{.spec.template.spec.serviceAccountName}")" = "pipeline-sa" ]'
chk 1 "builder image = nginx:1.25" \
  '[ "$('"$K"' -n venus get deploy builder -o jsonpath="{.spec.template.spec.containers[0].image}")" = "nginx:1.25" ]'
chk 1 "/tmp/ckad/q17.txt holds a JWT-shaped token" \
  'test -s /tmp/ckad/q17.txt && [ "$(tr -cd "." < /tmp/ckad/q17.txt | wc -c)" -ge 2 ]'

q Q18 "Disable token automount"
chk 1 "pod no-token exists in venus" "$K -n venus get pod no-token"
chk 2 "token genuinely not mounted (no projected SA volume or mount)" \
  "$K -n venus get pod no-token -o json | jq -e '(((.spec.volumes // []) | map(select(any(.projected.sources[]?; .serviceAccountToken != null))) | length) == 0) and (((.spec.containers[0].volumeMounts // []) | map(select(.mountPath | test(\"serviceaccount\"))) | length) == 0)'"
chk 1 "automountServiceAccountToken=false on the pod OR its ServiceAccount" \
  'SA=$('"$K"' -n venus get pod no-token -o jsonpath="{.spec.serviceAccountName}");
   [ "$('"$K"' -n venus get pod no-token -o jsonpath="{.spec.automountServiceAccountToken}")" = "false" ] ||
   [ "$('"$K"' -n venus get sa $SA -o jsonpath="{.automountServiceAccountToken}")" = "false" ]'

# ---------- Section G ----------
q Q19 "Taint and tolerate"
chk 2 "worker4 tainted workload=batch:NoSchedule" \
  "$K get node multi-node-cluster-worker4 -o json | jq -e '.spec.taints // [] | map(select(.key==\"workload\" and .value==\"batch\" and .effect==\"NoSchedule\")) | length == 1'"
chk 1 "batch-1 tolerates workload=batch:NoSchedule" \
  "$K -n mars get pod batch-1 -o json | jq -e '.spec.tolerations | map(select(.key==\"workload\" and (.value==\"batch\" or .operator==\"Exists\") and .effect==\"NoSchedule\")) | length >= 1'"
chk 1 "batch-1 uses a hostname nodeSelector" \
  '[ "$('"$K"' -n mars get pod batch-1 -o jsonpath="{.spec.nodeSelector.kubernetes\.io/hostname}")" = "multi-node-cluster-worker4" ]'
chk 2 "batch-1 Running on worker4" \
  '[ "$('"$K"' -n mars get pod batch-1 -o jsonpath="{.spec.nodeName}")" = "multi-node-cluster-worker4" ] &&
   [ "$('"$K"' -n mars get pod batch-1 -o jsonpath="{.status.phase}")" = "Running" ]'

q Q20 "Node affinity + tolerations"
chk 1 "pod edge-pod exists in mars" "$K -n mars get pod edge-pod"
chk 2 "required nodeAffinity: color In [red, blue]" \
  "$K -n mars get pod edge-pod -o json | jq -e '.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[].matchExpressions[] | select(.key==\"color\" and .operator==\"In\") | .values | (index(\"red\") != null and index(\"blue\") != null)'"
chk 2 "tolerates both color=red and color=blue NoSchedule" \
  "$K -n mars get pod edge-pod -o json | jq -e '(.spec.tolerations | map(select(.key==\"color\" and .value==\"red\")) | length >= 1) and (.spec.tolerations | map(select(.key==\"color\" and .value==\"blue\")) | length >= 1)'"
chk 1 "Running on worker or worker2" \
  "$K -n mars get pod edge-pod -o json | jq -e '.status.phase==\"Running\" and (.spec.nodeName==\"multi-node-cluster-worker\" or .spec.nodeName==\"multi-node-cluster-worker2\")'"

finish

# ---------- Summary ----------
printf "\n${B}=========================================================${N}\n"
printf "${B}  Per-question breakdown${N}\n"
printf "${B}=========================================================${N}\n"
for row in "${REPORT[@]}"; do
  IFS='|' read -r name s m <<< "$row"
  if   [ "$s" -eq "$m" ]; then c=$G
  elif [ "$s" -eq 0 ];    then c=$R
  else                         c=$Y; fi
  printf "  %-5s ${c}%2s / %-2s${N}\n" "$name" "$s" "$m"
done

PCT=$(( SCORE * 100 / MAX ))
printf "\n${B}---------------------------------------------------------${N}\n"
printf "${B}  TOTAL: %s / %s  (%s%%)${N}\n" "$SCORE" "$MAX" "$PCT"
if [ "$PCT" -ge 66 ]; then
  printf "  ${G}PASS${N} - CKAD cut score is 66%%\n"
else
  printf "  ${R}FAIL${N} - CKAD cut score is 66%%. Revisit the red questions above.\n"
fi
printf "${B}---------------------------------------------------------${N}\n"
