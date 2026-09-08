# "Where does this field go?" — the only map you need

The whole problem reduces to **two questions**, asked in order.

### Q1: Is this about the *controller* or about the *pod*?

`spec.template.spec` **is** the pod spec. In a Deployment / ReplicaSet / Job /
DaemonSet / StatefulSet, anything that describes a pod lives there — identical
to a bare Pod's `spec`, just nested deeper.

Only **8 fields** exist at `deployment.spec` level. Memorise this list and
everything not on it is a pod field:

```
replicas  selector  template  strategy
minReadySeconds  revisionHistoryLimit  paused  progressDeadlineSeconds
```

CronJob nests twice: `spec.jobTemplate.spec.template.spec` is the pod spec.
(`spec.schedule`, `spec.suspend`, `spec.concurrencyPolicy` are CronJob-level;
`spec.jobTemplate.spec.backoffLimit`, `.completions`, `.parallelism` are Job-level.)

### Q2: Is this about the *whole pod* or about *one container*?

| Pod-level (`spec.…`) | Container-level (`spec.containers[].…`) |
|---|---|
| `nodeSelector`, `affinity`, `tolerations` | `image`, `command`, `args`, `env`, `envFrom` |
| `serviceAccountName`, `automountServiceAccountToken` | `ports`, `resources` |
| `volumes` | `volumeMounts` |
| `restartPolicy`, `initContainers`, `hostNetwork` | `livenessProbe`, `readinessProbe`, `startupProbe` |
| `nodeName`, `priorityClassName`, `schedulerName` | `imagePullPolicy`, `lifecycle` |
| `terminationGracePeriodSeconds`, `dnsPolicy` | |

**`securityContext` exists at BOTH levels — and they hold different fields.**
This is the single most common mix-up:

| `spec.securityContext` (pod) | `spec.containers[].securityContext` |
|---|---|
| `runAsUser`, `runAsGroup`, `runAsNonRoot` | `runAsUser`, `runAsGroup`, `runAsNonRoot` |
| `fsGroup`, `fsGroupChangePolicy` | **`capabilities`** (add / drop) |
| `supplementalGroups`, `sysctls` | `privileged`, `allowPrivilegeEscalation` |
| `seccompProfile`, `seLinuxOptions` | `readOnlyRootFilesystem`, `procMount` |

Rules: **`capabilities` and `privileged` are container-only.** `fsGroup` and
`sysctls` are pod-only. Where both can appear, **container wins** (overrides pod).
`resources` is container-only — there is no pod-level `resources` you'd set by hand.

---

## Exam-legal lookups, fastest first

**1. Non-recursive `explain` = the field list for exactly one level.** This is the
move most people miss. No grep, no indentation counting:

```bash
kubectl explain pod.spec              # every pod-level field
kubectl explain pod.spec.containers   # every container-level field
kubectl explain deployment.spec       # the 8 controller fields
```

**2. Probe a guess — it costs one second.** `explain` tells you flatly if you're wrong:

```bash
kubectl explain pod.spec.capabilities
# error: field "capabilities" does not exist
kubectl explain pod.spec.containers.securityContext.capabilities
# KIND: Pod  FIELD: capabilities <Capabilities>  ✓
```

Guess → probe → correct. Faster than searching.

**3. Ask a live object.** Real objects show the true path with defaults filled in:

```bash
kubectl get pod <any-pod> -o yaml | less
kubectl run tmp --image=nginx --dry-run=client -o yaml   # skeleton
```

**4. The docs are open during the exam — use them.** kubernetes.io task pages have
complete copy-pasteable YAML. For tolerations/affinity/securityContext, copying
from the docs beats typing from memory. Bookmark:
- Assign Pods to Nodes / Taints and Tolerations
- Configure a Security Context for a Pod or Container
- Manage Resources for Containers

**Do NOT** use `explain --recursive | grep` under time pressure. Grep strips the
indentation, so you get the field name with no path — which is exactly the problem
you were trying to solve. Non-recursive `explain` at a specific level is strictly better.

---

## 30-second drill

Say the path out loud before checking. Answers at the bottom.

1. `maxSurge` on a Deployment
2. `capabilities` on a Deployment
3. `tolerations` on a CronJob
4. `fsGroup` on a Pod
5. `serviceAccountName` on a Deployment
6. `backoffLimit` on a CronJob
7. `volumeMounts` on a Pod
8. `readOnlyRootFilesystem` on a Job

<details><summary>Answers</summary>

1. `spec.strategy.rollingUpdate.maxSurge`
2. `spec.template.spec.containers[].securityContext.capabilities`
3. `spec.jobTemplate.spec.template.spec.tolerations`
4. `spec.securityContext.fsGroup`
5. `spec.template.spec.serviceAccountName`
6. `spec.jobTemplate.spec.backoffLimit`
7. `spec.containers[].volumeMounts`
8. `spec.template.spec.containers[].securityContext.readOnlyRootFilesystem`
</details>
