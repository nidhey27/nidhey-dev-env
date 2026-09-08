# CKAD Practice Test 01

**Total: 100 points · Suggested time: 60 minutes · Pass mark: 66**

Covers only what you have studied so far: RC/RS, labels & selectors, Deployments
(rollout/rollback), Services & DNS, imperative commands, SecurityContexts,
resource requests/limits, LimitRange, ResourceQuota, ServiceAccounts, Taints &
Tolerations, NodeSelector & NodeAffinity.

## Rules (read these — they are graded)

1. **Every question names a context. Switch to it before you start.**
   `kubectl config use-context ckad-<name>`
   Each context has a default namespace baked in, so you should not need `-n`.
   If you create a resource in the wrong namespace, that question scores 0.
2. Answer files go in `/tmp/ckad/`. Exact filenames matter.
3. You may use the Kubernetes docs. You may not use notes or AI.
4. When done: `./ckad-practice-01/grade.sh`

---

## Section A — Pods, ReplicationController & ReplicaSet (15 pts)

### Q1 — Imperative generation (4 pts)
**Context: `ckad-pluto`**

Generate the manifest for a pod named `nginx-solo` using image `nginx:1.25`
**without creating it**, and save the YAML to `/tmp/ckad/q1.yaml`.
Then create the pod from that file.

### Q2 — Repair a broken ReplicaSet (6 pts)
**Context: `ckad-pluto`**

A ReplicaSet named `web-rs` exists but none of its pods reach Running state.
Diagnose and fix it — the image should be `nginx:1.25`.
Once healthy, scale it to **5** replicas.

### Q3 — ReplicationController (5 pts)
**Context: `ckad-pluto`**

Create a **ReplicationController** (not a ReplicaSet) named `legacy-rc` with
**2** replicas running image `httpd:2.4`. The pod template must carry the label
`app=legacy`.

---

## Section B — Deployments, Rollouts, Labels (24 pts)

### Q4 — Create a Deployment (4 pts)
**Context: `ckad-neptune`**

Create a Deployment named `api-gw` with **4** replicas using image `nginx:1.24`.

### Q5 — Rolling update and rollback (7 pts)
**Context: `ckad-neptune`**

1. Update `api-gw` to image `nginx:1.25` and wait for the rollout to finish.
2. Now roll it **back** to the previous revision.
3. Write the image the deployment is running *after the rollback* into
   `/tmp/ckad/q5.txt` (just the image string, e.g. `nginx:1.99`).

### Q6 — Update strategy (5 pts)
**Context: `ckad-neptune`**

Configure the `api-gw` Deployment so that during a rolling update it may create
**2** extra pods above the desired count and is allowed **0** unavailable pods.

### Q7 — Query with selectors (4 pts)
**Context: `ckad-neptune`**

Several pods named `np-*` exist. Write the names of all pods that have
`env=prod` **and** whose `tier` is **not** `cache` into `/tmp/ckad/q7.txt`,
one name per line.

### Q8 — Apply labels in bulk (4 pts)
**Context: `ckad-neptune`**

Add the label `team=alpha` to **every** pod in this namespace that has
`env=dev`. Do not label any other pod.

---

## Section C — Services & DNS (13 pts)

### Q9 — ClusterIP Service (5 pts)
**Context: `ckad-neptune`**

Expose the `api-gw` Deployment with a ClusterIP Service named `api-gw-svc`
on port **80** targeting container port **80**.

### Q10 — NodePort Service (5 pts)
**Context: `ckad-neptune`**

Create a NodePort Service named `web-np` that selects pods with label
`env=prod`, listening on port **80**, target port **80**, and exposed on node
port **30081**.

### Q11 — Service DNS (3 pts)
**Context: `ckad-neptune`**

Write the **fully qualified cluster DNS name** of `api-gw-svc` into
`/tmp/ckad/q11.txt` (single line, no port).

---

## Section D — Security Contexts (10 pts)

### Q12 — runAsUser (5 pts)
**Context: `ckad-saturn`**

Create a pod named `secure-1` running image `busybox:1.36` with command
`sleep 3600`. It must run as user ID **1010**, set at the **pod** level.

### Q13 — Capabilities (5 pts)
**Context: `ckad-saturn`**

Create a pod named `secure-2` running image `busybox:1.36` with command
`sleep 3600`. Its container must be granted the capabilities **NET_ADMIN**
and **SYS_TIME**, and must drop **CHOWN**.

---

## Section E — Resources, LimitRange, ResourceQuota (16 pts)

### Q14 — Requests and limits (5 pts)
**Context: `ckad-saturn`**

Create a pod named `resource-1` with image `nginx:1.25` requesting
**100m** CPU / **256Mi** memory, limited to **500m** CPU / **512Mi** memory.

### Q15 — LimitRange (6 pts)
**Context: `ckad-mercury`**

Create a LimitRange named `cpu-mem-defaults` of type `Container` with:
- default limit: cpu `300m`, memory `512Mi`
- default request: cpu `100m`, memory `256Mi`
- max: cpu `1`
- min: cpu `50m`

Then create a pod `lr-test` with image `nginx:1.25` and **no** resource stanza,
and confirm the defaults were injected.

### Q16 — ResourceQuota (5 pts)
**Context: `ckad-mercury`**

Create a ResourceQuota named `mercury-quota` capping the namespace at
`requests.cpu=2`, `requests.memory=2Gi`, `limits.cpu=4`, `limits.memory=4Gi`,
and a maximum of **10** pods.

---

## Section F — Service Accounts (10 pts)

### Q17 — Create and attach a ServiceAccount (6 pts)
**Context: `ckad-venus`**

1. Create a ServiceAccount named `pipeline-sa`.
2. Create a Deployment named `builder` with image `nginx:1.25` that runs
   **as** `pipeline-sa`.
3. Generate a token for `pipeline-sa` and save it to `/tmp/ckad/q17.txt`.

### Q18 — Disable token automount (4 pts)
**Context: `ckad-venus`**

A pod named `no-token` exists. Recreate it so that the ServiceAccount token is
**not** mounted into it. Everything else about it stays the same.

---

## Section G — Taints, Tolerations, Node Affinity (12 pts)

> Node reference for this cluster:
> `multi-node-cluster-worker` (label+taint `color=red`),
> `worker2` (`color=blue`), `worker3` (`color=green`),
> `worker4` and `worker5` (clean).

### Q19 — Taint and tolerate (6 pts)
**Context: `ckad-mars`**

1. Taint node `multi-node-cluster-worker4` with `workload=batch:NoSchedule`.
2. Create a pod `batch-1` with image `nginx:1.25` that **tolerates** that taint
   and is **pinned** to `multi-node-cluster-worker4` using a `nodeSelector` on
   the node's hostname label. It must reach Running on that node.

### Q20 — Node affinity + tolerations combined (6 pts)
**Context: `ckad-mars`**

Create a pod `edge-pod` with image `nginx:1.25` that:
- uses `requiredDuringSchedulingIgnoredDuringExecution` node affinity matching
  label key `color` with operator `In` and values `red` **and** `blue`, and
- tolerates **both** the `color=red:NoSchedule` and `color=blue:NoSchedule` taints.

It must end up Running on either `multi-node-cluster-worker` or
`multi-node-cluster-worker2`.

---

## When you are done

```bash
./ckad-practice-01/grade.sh
```

To reset and retake:

```bash
./ckad-practice-01/cleanup.sh && ./ckad-practice-01/setup.sh
```
