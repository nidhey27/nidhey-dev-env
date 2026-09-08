# CKAD Progress Tracker — private

**Not in the git repo.** Lives in `~/Documents/nidhey-dev-env/kind/`, which is not
a git repository, so it cannot be committed by accident.

Target: **CKAD**, pass mark **66%**.

---

## Scoreboard

| Date | Test | Score | Time used | Attempted | Accuracy on attempted | Lost to not attempting |
|---|---|---|---|---|---|---|
| 2026-08-04 | 01 — Core & Scheduling | **92** | 60 min + retake | 20/20 | 96% | 8 |
| 2026-08-05 | 02 — Multi-container & Observability | **88**\* | 45 min | 18/20 | 98% | 10 |
| 2026-08-06 | 04 — Config, Jobs & Strategies | **75** | 56 min | 16/20 | 91% | 18 |
| 2026-08-06 | 05 — Exam-style scenarios | **75** † | 60 min | 10/11 | 82% | 9 |
| 2026-08-10 | 06 — Services & Networking | **90** ‡ | 51 min | 18/20 | 97% | 11 |
| 2026-08-12 | 07 — State Persistence & DaemonSets | **48/85** § | 60 min | 15/17 | 62% | 12 |
| 2026-08-14 | 08 — Storage & DaemonSet DRILL | **87** ¶ | 58 min | 19/20 | 92% | 5 |
| 2026-08-19 | 09 — Security: RBAC, CRDs, Admission | **82** ‖ | 61 min | 19/20 | 86% | 3 |
| 2026-08-20 | 10 — Helm | **84** | **22 min of 60** | 10/10 | 84% | 0 |
| 2026-08-25 | 11 — Kustomize | **92** ** | 41 min of 60 | 9/9 | **100%** | 8 |
| 2026-08-27 | 12 — Images & PSA | **75** ††† | 57 min of 60 | 10/11 | 82% | 8 |
| 2026-08-27 | **13 — FULL EXAM SIMULATION** | **95** ‡‡ | ~120 min | 17/17 | 95% | 0 |
| 2026-08-29 | 14 — Mock exam, 20 tasks | **75** ◇ | 110 min of 120 | 20/20 | 75% | 0 |
| 2026-08-28 | **KodeKloud Lightning Lab 1** (external) | **100** ◆ | 50 min of 60 | 5/5 | **100%** | 0 |
| 2026-08-30 | 20 — Mock exam F | **69** ◈ | 117 min of 120 | 19/20 | 73% | 5 |
| 2026-09-02 | **22 — DRILL: the test-20 gaps** | **73** ◉ | 87 min of 120 | 20/23 | **84%** | 13 |
| | 15-19, 21 — Mock exams A-E, G | *pending, 6 papers* | | | | |
| | 03 — Multi-container set B | *pending* | | | | |

◉ Drill 22 was built to close the six gaps test 20 exposed, in the narrow
repetition-heavy style of drill 08. Scored **73/100 overall, 84% on the 20 tasks
attempted**; Q12-Q14 were skipped as not understood.

**Three gaps are now closed:**

| Section | Score | Verdict |
|---|---|---|
| B - `fsGroup` vs `supplementalGroups` vs `runAsUser`/`runAsGroup` | **17/17** | closed |
| F - Ingress `defaultBackend`, `Exact` vs `Prefix` | **10/10** | closed |
| C - ResourceQuota scopes | 11/14 | closed; see the grader note below |
| G - taints, tolerations, nodeSelector, affinity | 13/15 | largely closed. Q22, where the right answer was to add NO toleration, scored 5/5 |
| E - NetworkPolicy selector types | 11/16 | **partly** |
| D - ephemeral containers | 0/13 | **untouched, not attempted** |

**Two things still open.**

1. **AND vs OR in a NetworkPolicy `from` list, inverted.** Q17 wanted AND and got
   two peers (which is OR); Q18 wanted OR and got a single peer. Both shapes are
   known, they are mapped to the wrong words. The whole difference is one dash:
   two keys in one list item is AND, two list items is OR.
2. **Ephemeral containers**, 13 points, skipped entirely. An explanation in prose
   did not land. Next step agreed: work `kubectl debug` hands-on against a live
   Pod rather than reading about it again.

Small misses: `flint-disk1` and `red-only` never created; the Q10 PriorityClass
made at `1000000` instead of `100000`; Q11's Service named `drift-a` rather than
`drift-svc`.

**Two more grader bugs of mine, found here (numbers 9 and 10).** Their quota
answers used `scopeSelector` with `BestEffort`/`Exists` and `count/pods`, where the
grader demanded `scopes: [BestEffort]` and `pods`. Both spellings are valid and
both were enforcing correctly - `used` matched `hard` on the live objects. Fixed
with `qhard`/`qused`/`qhas_scope` helpers that accept either dialect. That moved
the score from 64 to 73.

◈ Test 20 is **locked at 69**, and this needs stating carefully because I first
recorded it as 82, which was wrong. Nidhey caught it.

- **Submitted score: 64.**
- **+5 for a grader bug of mine (number 8):** their `spinel-besteffort` quota used
  `count/pods` where the grader demanded `pods`. It was created during the clock and
  was enforcing correctly - `used` matched `hard`, a third BestEffort Pod was
  refused, a Burstable one admitted. Those 5 points were earned during the sitting,
  so they count. **69.**
- Everything else came after the clock: their own fix to Q1, creating the `vaulted`
  Pod for Q14, and a further grader correction splitting Q14's mode and env checks.
  Untimed, that reaches **82**. Practice, not the score - the same convention as
  tests 05, 06 and drill 08.

It remains the hardest paper in the set: 24 checks graded by real effect against
test 14's 7.

**The knowledge-gap assessment was therefore too pessimistic.** Of the 36 points
first thought lost, quota scopes were correct and the `emptyDir` loss was a typo
(`medium: Medium` for `Memory`, which the API accepts silently and which leaves the
Pod in ContainerCreating with nothing on the Pod to explain it). Genuine gaps were
about 17 points, not 27.

The original note stands otherwise: test 20 was **the first paper where losses were
mostly knowledge rather than execution.** It is also the hardest
paper in the set: 24 checks graded by real effect against test 14's 7, so a wrong
answer loses a whole check rather than one of five.

Of 36 points lost, roughly 27 were things never learned or never practised:

| Q | Pts | Gap |
|---|---|---|
| 13 | 5 | `ResourceQuota` **scopes** - "not aware of concept", their words |
| 11 | 5 | Ephemeral containers / `kubectl debug`. Added a normal container named `debug` instead, which replaces the Pod - the one thing the task forbade |
| 3 | 5 | `emptyDir` `medium: Memory` for a RAM-backed volume; wrote only `sizeLimit` |
| 15 | 5 | `supplementalGroups: [4000]` where `fsGroup: 4000` was wanted. The Pod then CrashLooped, because supplementalGroups does not change volume ownership so the container could not write to its emptyDir |
| 19 | 5 | `namespaceSelector` where `podSelector` was needed - matched namespaces carrying the label rather than pods |
| 20 | 2 | Ingress `defaultBackend` |

The remaining 9 were reading: Q5 added a toleration although the task said "No
tolerations of any kind" (tolerations permit, they do not confine - the lesson from
day one), Q14's Secret was created correctly with both keys but the Pod that
consumes it never was, and Q1's adapter container was never added.

**`kubectl debug` works on this cluster** - verified end to end, the ephemeral
container reaches Running and fetches over localhost. The trap is that
`kubectl debug ... -- <cmd>` attaches and looks hung while the container is still
being created. Naming the container with `--container` and exec'ing into it
separately is reliable.

◇ Test 14: all 20 attempted, finished with 10:14 spare. **No grader fault - every
loss was a name or a value.** Four of the five failures were identifier or
transposition errors, not concepts:

| Q | Lost | What happened |
|---|---|---|
| 11 | 5 | Helm release created as **`fronax-web`**, asked for `fornax-web`. The install and the upgrade were both correct |
| 17 | 4 | RoleBinding's `roleRef` named `Role/reporter`; the Role is `reporter-role`. A dangling roleRef is accepted silently and grants nothing |
| 15 | 3 | PVC omitted `storageClassName`, so DefaultStorageClass injected `standard` and it could never bind to a class-less PV |
| 20 | 3 | requests and limits **swapped** (4/4Gi and 2/2Gi instead of 2/2Gi and 4/4Gi), and `pods: 10` missing entirely |
| 8 | 1 | Readiness probe `["sh","-c","-e","<file>"]` - `sh -c` takes the command as its next argument, so the file was executed. Should be `test -e <file>` |

By domain: Services and Networking **19/20**, Observability 12/15, Design and Build
15/20, Deployment 13/20, Environment/Config/Security 16/25. **Networking is now the
strongest domain**, a complete reversal from test 06 where it was the weakest.

Q15 is a repeat of drill 08 Q7, already written up in this file as a rule. Test 14
did document the default StorageClass, but in a lab-notes block ~100 lines below the
question; the note is now also inline at Q15. Papers 15, 17 and 19 were checked and
do not share the trap - each seeds PVs with a named class and says so in the task.

◆ Lightning Lab 1 is **KodeKloud's paper, graded by KodeKloud** - the first
external, independently-graded result in this record, and the first 100%. Pass mark
was 80. Five questions: a PV/PVC/Pod storage chain, a Service plus NetworkPolicy
troubleshoot, a ConfigMap-driven command with a persistent volume, a Deployment with
`maxSurge`/`maxUnavailable` upgraded then rolled back, and a Redis Deployment with
emptyDir and ConfigMap volumes.

**Q2 is the significant one.** A misconfigured Service combined with a default-deny
NetworkPolicy - precisely the shape that cost 3 points on test 13 Q15, where
`get endpoints` reported healthy while the ports were wrong. Solved cleanly here, on
an external grader, unprompted. That is the first hard evidence that weakness #0 is
actually closing rather than just being described.

‡‡ Test 13 is the **first full-length, all-domains, 2-hour paper** — 17 tasks,
weights following the published curriculum distribution, no indication of what was
being graded. Raw grader score 90; Q5 credited on review, giving **95**.

Q5 was **my defect, not an execution error.** I first wrote the task around
`nginx:1.26`, discovered during validation that this cluster cannot pull it, and
changed the task to `nginx:1.24` — after the paper had already been handed over,
and without saying so. Their canary was structurally perfect (1 replica, labels
`app=storefront` matching the Service selector, would have taken endpoints to 4);
the only blocker was an image cached on zero nodes. `nginx:1.26` appears nowhere in
this project except that first draft, and their pod carried `track: stable`, so they
had copied the stable manifest and taken the tag from the question text they were
looking at. **Third instance of my activity interfering with a live sitting.**

Fixed properly rather than patched: `tests/lib.sh` gained
`require_images_available`, and test 13's `setup.sh` now refuses to hand over the
paper unless every image it names is cached or pullable. A task whose image will not
pull is unwinnable, and the candidate cannot tell that apart from their own mistake.

††† Test 12: I again ran `cleanup.sh && setup.sh` mid-sitting, during Q1. Their
built image survived (grading checks the image, not the Dockerfile) so no points
were lost, but `setup.sh` overwrote their two-stage Dockerfile and recreated the
already-fixed `puller` pod, so some of the 57 minutes went on redoing my damage.
**Second occurrence. Read [[never-touch-cluster-during-test]] before running
anything against the cluster.**

** Test 11: Q10 (Kustomize Components) was **deliberately skipped** and is the
entire 8-point gap. Components are not named in the CKAD curriculum and the
question said so in bold. Skipping it with 18:35 still on the clock was correct
triage, not an omission. **Everything attempted scored full marks.**

‖ Test 09 was scored by **reconstruction, not by the grader**. Claude ran
`cleanup.sh && setup.sh` at 21:37:52, ~50 minutes into the sitting, to validate a
grader fix. That deleted all five namespaces plus the cluster-scoped ClusterRoles
and CRDs, destroying the live state for Q1-Q14. `grade.sh` then reported **18**.
The 82 was rebuilt from `~/.zsh_history` (timestamped), the eight answer manifests
in the test directory, and two surviving `/var/folders/**/kubectl-edit-*` temp
files. Q2 could not be verified from any artefact and is credited on Nidhey's
account; the `k edit roles pod-reader` at 20:54:53 left no temp file, and kubectl
only preserves those when the edit **fails**, so that edit did apply.

\* Test 02 was 67 on the first sitting, 88 on a retake of the **same paper** — the
retake is contaminated by familiarity and is not a clean measurement. Test 03
exists to give an uncontaminated read of the same syllabus.

¶ Drill 08 is **locked at 87**. Q4, Q7 and Q11 were redone untimed the same day
and all scored full marks, taking the paper to **98/100**. Only Q9's reason file
was left undone. **Nothing on that paper was beyond reach** — every loss was an
omitted field, an unverified command, or a file not written. No concept gaps.

§ Test 07 is scored out of **85 CKAD-scope points**; Section D (StatefulSets,
headless Services) is off-syllabus and excluded. Section D was correctly skipped.
The 48 is depressed by a namespace error, not by knowledge — see weakness #1b.

‡ Test 06 is **locked at 90**. Q9 and Q13 were completed afterwards as untimed
practice and do **not** count — with them the paper would have been **98/100**.
Both were fully correct on the untimed attempt: Q9 used the correct AND form
(namespaceSelector and podSelector inside a single `from` item) and passed all
three traffic probes; Q13 was already correct on the timed attempt except for its
name. **Nothing on test 06 was beyond reach** — the 10 lost points were two
unopened questions and one unchanged field.

† Test 05 is **locked at 75**. Q6 and Q8 were worked through afterwards as
untimed practice on 2026-08-08 and do **not** count. Re-running `grade.sh` on the
test 05 namespaces will show a higher number — that is practice, not the score.

**Headline:** accuracy on attempted work has been 82–100%. Test 10 is the only
sitting where a point was lost to genuinely not knowing something (the
`helm upgrade` values-reset rule, 4 pts). Everything else, across eleven papers,
has been execution.

**Test 11 is the first clean sheet: 100% accuracy on attempted work, nothing
half-built, nothing unverified, and the answer file written.** Nine questions, nine
full scores. The only points not earned were on a question deliberately and
correctly skipped as off-syllabus.

**Test 10 is the best-executed paper so far**: 10 of 10 attempted, nothing skipped,
finished in **22 minutes with 37:39 left** — a third of the clock. And it is the
first time the two planted weak-spot questions were both taken cleanly: Q9 (exact
resource values, after test 09's Q20 went 1/5) scored 10/10, and Q10 (the same
NetworkPolicy that the `taregt` typo cost 3 points on) scored 10/10 including both
traffic probes. Q5, a diagnose-and-repair question aimed straight at weakness #0,
also scored 10/10.

**Best CKAD-scope result: drill 08, 87/100** (2026-08-14) — and the point of it
was closing the test 07 gap. **Section D, DaemonSets: 25/25**, average 2:26 per
question, having scored **2/9** on the same concepts two days earlier. Section C
(StorageClass) also perfect. Deliberate targeted drilling worked.

**Previous best on a broad test: test 06, 90/100** — 18 of 20 attempted, 97% accuracy, and
finished with 8:39 left. Notably this was on Services & Networking, previously the
weakest domain, at first attempt.

**Trajectory:** the coverage problem (test 02–04) was fixed by test 05. Precision
then dipped to 82%. Test 06 fixed both at once — 18/20 attempted at 97% accuracy,
finishing early. Both original weaknesses are now closed.

| | Test 04 | Test 05 | Test 06 |
|---|---|---|---|
| Attempted | 16/20 | 10/11 | **18/20** |
| Accuracy | 91% | 82% | **97%** |
| Time used | 56 min | 60 min | **51 min** |

---

## Recurring weaknesses

Ranked by how much they have actually cost.

### 0. THE DIAGNOSTIC LOOP STOPS ONE STEP SHORT — now the live #1
As of test 09 this is the top cost, and it absorbs old weaknesses 1b and 3b. The
pattern: **the symptom gets confirmed, the object never gets read.**

Test 09, three instances in one paper:

| Q | What was done | The missing step | Cost |
|---|---|---|---|
| Q12 | `k get crd`, `get crds`, `get crds -A`, `kubectl -n cipher get backups`, `kubectl get backups` — the symptom confirmed **five** ways in 66 seconds | `k get crd backups.storage.example.com -o yaml`, then compare `served` against `storage`. The fault was one boolean | **7** |
| Q19 | Spotted the port was wrong, `k edit netpol target-allow`, fixed 8080 → 80 | Re-read the `podSelector` in the same buffer — it said `app: taregt`. No traffic test after the edit, though the question states it is graded by traffic | **3** |
| Q5 | `auth can-i list secrets --as reader-sa`, then `--as sentry:reader-sa` | Neither is a real subject. The correct form is `--as system:serviceaccount:sentry:reader-sa`. The answer was right, but the check could not have told the difference | 0 (lucky) |

Q5 is the important one even though it cost nothing: **a verification that cannot
fail is not a verification.** Both invocations return "no" for a correct answer and
a wrong one alike.

Contrast with what works: on Q4 and Q7 the check was a positive *and* a negative
(`can-i create deployments --as ops-user` yes, `create pods` no; `create pv` yes,
`delete pods` no). Both scored full marks. On Q1 a failed check drove a real
diagnosis — the `roleRef` immutability error, resolved with `replace --force`,
which is above CKAD level.

**Rules:**
- After any `edit` / `patch` / `apply`, `get -o yaml` the object and read the
  **whole** spec, not the field just changed.
- When a question says it is graded by traffic, send traffic.
- Confirming a symptom repeatedly is not diagnosis. One `-o yaml` on the broken
  object beats five `get`s.
- Impersonating a ServiceAccount is `--as system:serviceaccount:<ns>:<name>`.
- Prove a permission check works by making it say **no** once.

### 0b. ANSWER FILES — three papers running, then broken on test 11
**Test 11 wrote `q9-cause.txt` and scored the 2 points.** First paper in four
without an answer-file loss. Keep the habit: when a question names a file, `cat` it
before moving on.

Historical record below, kept because the streak was long enough to matter.


Three papers running, points have gone to answer files rather than to Kubernetes.
Test 10 lost **9 of its 16** points this way, with 37 minutes left on the clock:

| Q | Asked for | Written |
|---|---|---|
| Q2 (6 pts) | two values, space-separated, one line, with the shape shown in the question | the **entire 30KB** `helm show values` dump, redirected raw |
| Q7 (3 pts) | the revision number | file never created |

Q2 is weakness #6 returning: **redirecting a command's whole output instead of
extracting the answer from it.** The answer was in the file, buried in 700 lines of
Bitnami comments. Drill 08 lost `q9-reason.txt`, test 09 lost `q9-cause.txt`, test
10 lost `q7-revision.txt` — three consecutive papers with a missing answer file.

**Rule: when a question names a file, `cat` it before moving on.** Two seconds each.
On test 10 there were 37 spare minutes and four answer files; none were re-read.

### 1. WRONG NAMESPACE — REOPENED on test 12
Marked closed after test 09's in-flight self-catch. It returned on **test 12 Q5**,
worth 8 points: the PSA labels went onto **`harbor`** instead of **`bulwark`**, and
`harbor` was the namespace they had been working in for the previous four questions.

The twist worth internalising: **`kubectl label ns <name>` takes an explicit name,
so switching context does not protect you.** Namespaces are cluster-scoped. Every
habit built for this weakness — `kc ckad-<ns>` first, `-n` on every command — is
useless here. For any cluster-scoped object (namespaces, nodes, PVs, ClusterRoles,
CRDs, StorageClasses) the name in the command **is** the target. Re-read it against
the question before pressing enter.

### 1a. WRONG NAMESPACE — the original, namespaced-object form
Test 07: Q15 is in `ckad-zinc`, Q16-Q18 and Q20 are in `ckad-copper`. After
switching to zinc for Q15, **the context was never switched back**. Everything
for Q16-Q20 was created in `zinc`:

| Object | Landed in | Should have been | Content |
|---|---|---|---|
| `cat-cm` / `cat-sec` / `cat-consumer` | zinc | copper | **correct** |
| `probed` (startup probe) | zinc | copper | **correct** |
| `catalog` rollout | zinc | copper | **correct** (rev 3, nginx:1.24) |
| `pages-ing` | zinc | copper | partial |
| `emitter` | nowhere | **zinc** | never created |

**At least 15 points of correct work scored zero.** Ironically the one question
that did belong in `zinc` (Q19) was the one missed.

**Fix — pick one and do it every single question:**
- `kubectl config use-context ckad-<ns>` as the *first action* of every question,
  even when you believe you are already there; or
- drop contexts entirely and pass `-n <ns>` on every command, so the namespace is
  visible in the command instead of hidden in state.

Nothing at the prompt distinguishes `ckad-zinc` from `ckad-copper`.

**Test 09: FIXED, and self-caught for the first time.** The habit is now visible in
the history — `kc ckad-<ns>` appears as the opening command of essentially every
question, 14 times across the sitting. On Q17 the SA and pod were built in
`bastion` at 21:40 while still in the previous question's context; at 21:42:29
Nidhey noticed unprompted, switched to `ckad-keystone` and rebuilt both correctly.
**Nobody pointed it out.** That is the first time this error was caught in-flight
rather than at grading. Treat weakness #1 as closed and stop spending time on it.

### 1b. Verification — reading the question back against what was built
Test 05 lost 6 points to two wrong values, neither a knowledge gap:

| Q | Asked | Written |
|---|---|---|
| Q1 | requests `100m` / `128Mi` | `50m` / `64Mi` (and a `99m` limit — typo) |
| Q5 | every minute → `*/1 * * * *` | `5 * * * *` — minute 5 of each hour, so it never fired |

Both would be caught by ten seconds of `kubectl get ... -o yaml` diffed
against the question text. Now that questions are being finished with time in
hand, spend some of it verifying.

Test 06 repeated it once: Q18's CronJob had `successfulJobsHistoryLimit: 3` where
the question said **2**. Everything else in that question was right. Two points
for one digit, with 8:39 left on the clock unspent.

**Superseded by weakness #0**, which is the same failure seen more precisely: the
object is never read back. Budget the last five minutes for
`kubectl get <resource> -o yaml` against the question text.

Drill 08 repeated the shape once more: **Q7 left `storageClassName` unset**, so
the default `standard` was injected and the claim could not bind to `shared-pv`
(class `shared`). `volumeName` alone does **not** override the class. That single
omitted field also left Q11's pod Pending — **one field, 6 points**, the same
cascade as test 06 Q5→Q11 and test 07 Q7→Q11.

**Rule: a PVC binds only to a PV in the SAME StorageClass.** If you name a
`volumeName`, name the class too. Confirmed on the untimed retry: adding
`storageClassName: shared` was the entire fix, and it recovered Q11 as well.

**The dependent-question cascade has now appeared three times** — test 06 Q5→Q11,
test 07 Q7→Q11, drill 08 Q7→Q11. When a question says it needs something from an
earlier one, verify that earlier thing actually works before building on it.

Drill 08 also lost 2 points to a missing `q9-reason.txt` while q8 and q10 were
written — an omission mid-sequence, not a misunderstanding.

**Cron reminder:** every minute is `*/1 * * * *` (or `* * * * *`).
`5 * * * *` is *minute 5 of every hour*.

**Not a mistake, but worth knowing** — Q11 used `maxSurge: 25%` where the question
said "one extra pod". For 3 replicas that is correct: maxSurge rounds **up**
(0.25x3 = 0.75 -> 1) and maxUnavailable rounds **down**. It would *not* be
equivalent at 10 replicas (25% -> 3). Rule: when a question names a **count**,
write the integer; when it names a **proportion**, write the percentage.

### 2. The copy-paste boundary — `metadata.name` and `namespace`
Test 06 Q13 scored **0/5** with every graded field correct. The annotation, path,
pathType and backend were all right; the resource was still called
`minimal-ingress`, the name from the Kubernetes docs example it was copied from.
Renaming it made it 5/5 with no other change.

Combined with test 05's `50m`/`64Mi` and test 06's `historyLimit: 3`, the pattern
is clear: **the fields that get missed are the ones already filled in by the
snippet.** The hard parts are consistently right.

**Rule: when lifting YAML from the docs, fix `metadata.name` and
`metadata.namespace` FIRST, before touching anything else.**

Test 10 Q4 repeated it at small scale: the question said `message: anvil-build`,
the values file said **`anvil-message`**. Everything structural about that question
was right - a full values file derived from `helm show values`, correct replica
count, correct release name and namespace, installed with `-f`. One literal string,
3 points.

**Test 09 Q20 is the worst single instance yet — 1/5, and the only knowledge-free
question on the paper.** Asked for requests `80m` / `64Mi` and limits `250m` /
`192Mi`. Written:

| | Asked | Written |
|---|---|---|
| requests.cpu | `80m` | `250m` |
| requests.memory | `64Mi` | `64Mi` ✅ |
| limits.cpu | `250m` | `500m` |
| limits.memory | `192Mi` | `128Mi` |

Three of four numbers wrong, and `250m` landed in the requests slot — the value
that belonged in `limits.cpu`. This is the docs-example resources block
(`64Mi`/`250m`, `128Mi`/`500m`) reproduced verbatim. The structure was perfect;
none of the values were the question's.

Every loss in this family is now the same shape: **the snippet's defaults were
left in place.** `minimal-ingress` (test 06 Q13), `historyLimit: 3` (test 06 Q18),
`50m`/`64Mi` (test 05 Q1), and now all four resource values. **Type the numbers
from the question in by hand before anything else, then diff them once.**

### 3. Half-built answers — 10 points, test 05 Q6
Created pod `audit` with `kubectl run` and none of the requirements: wrong
ServiceAccount (`default`), no securityContext, no capabilities, token still
mounted. Flagged "review/partial" and never revisited.

A shell with no substance scores the same as an untouched question **and** costs
the time. Either finish it or leave it.

### 3b. Silent failures — verify the command actually took effect
Drill 08 Q4: the timeline shows ~5 minutes spent, but `released-pv` was never
patched (its `claimRef.uid` was still the original seed value) and no `rescue-pvc`
was ever created. Time was spent; nothing landed. Likely a rejected patch or an
edit that never applied.

**After any `patch` / `edit` / `apply`, read the object back.** `kubectl get pv X`
takes two seconds and is the difference between 5 wasted minutes and 5 points.

### 4. Running out of road before the last section
Test 07 again, separately from the namespace error: Q10/Q11 (DaemonSets) consumed
the remaining clock and Q19 was never reached. Same shape as before — over-invest
in the hard section, never reach material already known cold.
**The 5-minute stop-loss remains unapplied.**

### 4b. Leaving whole questions unopened — was the biggest drain, now IMPROVING
Historically the largest loss, and always **the first section**:

| Test | Skipped | Cost |
|---|---|---|
| 02 (1st) | Section A (Q1–Q3) + all of Section D | 33 |
| 02 (2nd) | Q3 (and Q11 by dependency) | 10 |
| 04 | Section A (Q1–Q3) + Q11 | 18 |
| **05** | **Q8 only** | **9** |
| **06** | **Q9 and Q13** | **9** |

In test 04 the skipped questions were the *easiest on the paper* — 14 points of
basic YAML, roughly 6 minutes of work.

**Test 05 broke the pattern**: 10 of 11 attempted, and the first question was
done first. Keep watching that it does not return.

### 5. No stop-loss on a question going badly
Test 04 Q13 ran **9:03** for **3 of 6 points**. That single overrun was longer
than the three questions never attempted would have taken.
**Rule: past ~1.5× the budget, leave it.**

### 6. Answer files in the wrong place — 11 points, test 04
Correct content written to `/tmp/ckad/` instead of `/tmp/ckad/02/`.
Also: redirecting a raw `kubectl get` table instead of `-o name` / `--no-headers`.

### 7. Generating YAML and never applying it
Test 02: `twin.yaml` was correct and sat on disk unapplied for the whole test.
**`--dry-run -o yaml > f.yaml` and `apply -f f.yaml` are one action.**

### 8. `sh -c` with multiple array elements
`["sh","-c","cmd1","cmd2"]` silently discards `cmd2` as `$0`; the container exits.
Join with `&&` in a single string. Cost a crash-looping writer in test 02.

### 9. `kubectl create deployment` does not set custom pod labels (FIXED in test 05)
It labels pods `app=<deployment-name>`. Canary and blue/green are **pure label
mechanics**, so this broke both in test 04:
- canary never joined the Service (3 endpoints instead of 4)
- blue/green cutover pointed the Service at a label nothing carried → **0
  endpoints, a total outage**

Generate the YAML and edit `spec.template.metadata.labels` by hand.

### 10. Deleting seeded resources that were not meant to be touched
Test 04: deleted and recreated `color-blue`, which wasted time and broke labels.

---

## Timing analysis — test 04 (the only sitting with per-question data)

Reconstructed from object `creationTimestamp`s. Budget = 0.6 min per point.

| Q | Pts | Actual | Budget | Delta |
|---|---|---|---|---|
| Q14 multi-container | 5 | 8:38 | 3:00 | +5:38 🔴 |
| Q15 probes | 5 | 3:51 | 3:00 | +0:51 |
| Q16 securityContext | 4 | 3:39 | 2:24 | +1:15 |
| Q17 resources | 4 | 2:24 | 2:24 | ✅ |
| Q18 scheduling | 4 | 3:00 | 2:24 | +0:36 |
| Q19 ServiceAccount | 4 | 2:15 | 2:24 | ✅ |
| Q20 rollout | 4 | ~3:00 | 2:24 | +0:36 |
| Q4 ConfigMap | 5 | ~2:59 | 3:00 | ✅ |
| Q5 CM volume | 6 | 4:23 | 3:36 | +0:47 |
| Q6 Secret envFrom | 5 | 3:52 | 3:00 | +0:52 |
| Q7 Secret volume | 6 | 5:33 | 3:36 | +1:57 🔴 |
| Q8 Job | 6 | 2:45 | 3:36 | ✅ |
| Q13 blue/green | 6 | 9:03 | 3:36 | +5:27 🔴 |
| Q12 canary | 6 | 2:56 | 3:36 | ✅ |

**Throughput: 0.68 min/point vs a 0.60 budget — about 13% slow.** Not a speed
problem. A triage problem: the three red rows are 13 minutes over, which is
exactly the missing section.

Note: fastest questions were also the most accurate. Slowing down usually means
fighting something that should have been abandoned.

---

## The strategy to execute

1. **One pass through every question.** Answer anything doable in ~2 minutes on
   the spot; note the rest. Never a pure-reading phase — that produces nothing.
2. **Round 2:** the heavy YAML questions.
3. **Round 3:** leftovers and checking.
4. **Hard stop** at ~5 min (short-format tests) or ~8 min (exam-style) per
   question.

Rough split — 60 min: 20 / 30 / 10. Real exam 120 min: 35 / 65 / 20.

Budget per question: **0.6 min per point** → 4 pts ≈ 2:24, 6 pts ≈ 3:36.

---

## Syllabus coverage

Course sections 1-8 done. Security module completed 2026-08-18. Roughly **90%** of
the official curriculum, measured against the 24 named bullets.

| Domain | Weight | Covered | State |
|---|---|---|---|
| Services & Networking | 20% | **~100%** ✅ | NetworkPolicies, Services, Ingress — all tested |
| Observability & Maintenance | 15% | **~100%** ✅ | probes, logs, `top`, debugging, API deprecations |
| Environment, Config & Security | 25% | **~100%** ✅ | RBAC, CRDs, admission and quotas now tested hands-on (test 09). Only PSA left |
| Design & Build | 20% | ~90% | 1 real gap (below) |
| **Application Deployment** | **20%** | **~100%** ✅ | Helm 2026-08-20 (test 10), Kustomize 2026-08-24 (test 11) |

### No substantial gaps left

Kustomize was the last curriculum bullet with zero coverage; studied 2026-08-24 and
test 11 built the same day. What remains is small: container images and Pod
Security Admission, roughly 90 minutes together.

### Real but small gaps

| Gap | Domain | Why it matters | Effort |
|---|---|---|---|
| **Container images** — Dockerfile, multi-stage, `docker build/tag/push`, `imagePullSecrets` | Design & Build | The exam preamble asks for comfort with "(OCI-compliant) container images". Only the `ENTRYPOINT`→`command` mapping is known | ~1 hr |
| **Pod Security Admission** | Env/Config/Security | The "etc." in "SecurityContexts, Capabilities, etc." Replaced PodSecurityPolicy. Three levels + namespace labels | 20 min |

**RBAC and CRDs: closed 2026-08-19.** Test 09 scored 40/40 on RBAC (Q1-Q8) and
13/20 on CRDs, the 7 being Q12's unfinished repair rather than anything
misunderstood. `kubectl create role/rolebinding/clusterrole` imperatives were used
fluently, plural resources were right throughout, `--resource-name` for
`resourceNames` was right first time, `apps` and `storage.k8s.io` group membership
was right without checking, and `RoleBinding` → `ClusterRole` for namespace-scoping
was right. Writing a CRD from scratch including `openAPIV3Schema` bounds scored
7/7. **No RBAC or CRD knowledge gap remains.**

### Recommended order

1. **Container images** — Dockerfile and multi-stage
2. **Pod Security Admission** — 20 minutes, then done with the 25% domain
3. **Test 03**, then a full 2-hour mixed simulation across all domains

---

## Notes on the practice tests themselves

- Tests are at `~/Documents/ckad-practice-lab` (public repo, `nidhey27/ckad-practice-lab`).
- Run with `CKAD_CLUSTER=multi-node-cluster`.
- Scores here are **not** direct CKAD predictions — the question shapes differ.
  Test 05 is closest to the real format (11 weighted scenarios).
- The 45-minute limit originally used for tests 02/03 was miscalibrated and was
  corrected to 60 minutes. Some of the "unattempted" damage on test 02 was that
  clock, not a discipline failure.
- From test 05 onward the timer is started **after** reading the instructions,
  matching how the real exam works.
- Several graders have been too strict, asserting *how* something was done rather
  than *whether* it was done. Fixed so far: test 01 Q19 (nodeSelector vs hostname
  affinity), test 02 Q18 (SA-level vs pod-level automount), test 02 Q2 (volume
  name double-penalty), test 05 Q3 (httpGet vs tcpSocket) and test 05 Q11
  (surge/unavailable double-penalty, then literal-vs-effective maxSurge). Re-grade rather than assume a low score is
  the candidate's fault.

---

## Log

**2026-08-04** — Test 01: 82 first pass (17/20 in 60 min), 91 after retaking
Q18–Q20 in 12:14, 92 after a grader fix on Q19. Verified the taints/affinity
lab: tolerations permit, they do not reserve.

**2026-08-05** — Test 02: 67 first sitting (13/20 in 45 min). Retake 88, but
same paper so contaminated — flagged this themselves, correctly. Published the
practice lab as a public repo. Set up personal GitHub SSH alongside work GitLab.

**2026-08-06** — Test 04: 75 (16/20 in 56 min). Q12/Q13 partial from the
`create deployment` label issue. Per-question timing reconstructed. Requested
exam-style question format → test 05 built.

**2026-08-06 (evening)** — Test 05 (exam-style): **73/100**, 10 of 11 attempted
in a strict 60 minutes, timer started after reading instructions. Q2/Q4/Q7/Q9/Q10
full marks. Notably Q4 canary scored 10/10 — the exact label mechanic that scored
2/6 in test 04, so that lesson stuck. Q6 abandoned half-built (10 pts). Q8 not
attempted (9 pts). Initial grade was 69; two grader bugs of mine accounted for the
other 4 (Q3 demanded httpGet when tcpSocket was valid; Q11 double-penalised one mistake).
Later corrected again to **75** after confirming `maxSurge: 25%` on 3 replicas
does resolve to exactly one extra pod — the grader had demanded a literal 1.

**2026-08-08** — Cluster was wiped (Docker cleared). Rebuilt from the repo as
`ckad-lab`. Two host-level fixes were needed and are now permanent: Colima raised
to 8 CPU / 16 GiB, and `fs.inotify.max_user_instances` raised from 128 to 8192 in
`/etc/sysctl.d/99-kind.conf` inside the VM — the inotify limit was the real cause
of multi-node kubeadm join failures. Confirmed kindnet **does** enforce
NetworkPolicy (ingress podSelector, namespaceSelector, egress, ports), so no
Calico needed. Built test 06 over Services & Networking.

**2026-08-10** — Test 06: **90/100**, 18 of 20 attempted in 51 of 60 minutes.
Best result to date and on the weakest domain. All NetworkPolicy questions graded
by real traffic; deny-all, port-scoped allow, namespaceSelector and egress all
correct. Missed: Q9 (the AND-vs-OR selector trap, not attempted) and Q13
(rewrite-target Ingress, not attempted). Q18 lost 2 points to a wrong history
limit. Installed ingress-nginx themselves; `nginx` IngressClass is **not** default,
so Ingresses need `spec.ingressClassName: nginx` to actually route.

**2026-08-10 (later)** — Completed test 06 Q9 and Q13 untimed. Both fully
correct; the paper would have been 98/100. Q13's only fault had been the
docs-default name `minimal-ingress`.

**2026-08-12** — Test 07 (State Persistence & DaemonSets): **48/85 CKAD-scope**.
Section D correctly skipped as off-syllabus. Q1-Q9 largely solid: PV creation,
static binding, consuming a claim, StorageClass and dynamic provisioning all
scored. Two real gaps: **DaemonSet tolerations/nodeSelector** (Q10 not created,
Q11 created with neither field so 0 pods) and a **whole-section namespace error**
on Q16-Q20. Also hit the `Retain` PV trap live — deleting a PVC leaves the PV
`Released` with a stale `claimRef`, and it refuses to rebind until
`kubectl patch pv X -p '{"spec":{"claimRef":null}}'`.

**2026-08-14** — Drill 08 (PV/PVC/StorageClass/DaemonSets): **87/100**, 19 of 20
attempted in ~58 min, 92% accuracy on attempted. **Section D 25/25** and Section C
20/20 — the test 07 DaemonSet gap is closed. Losses: Q7's missing
`storageClassName` (cascaded into Q11, 6 pts), Q4 attempted but nothing landed
(5 pts), and a missing `q9-reason.txt` (2 pts). Also added to the repo cheat sheet
a full **Labels, Selectors & Scheduling** section (it had zero coverage of
taints/tolerations/affinity, because those are not named in the 24 curriculum
bullets) and a **Terminal setup** section with their own aliases
(`k`, `kdr`, `kc`) and vimrc.

**2026-08-14 (later)** — Redid drill 08 Q4, Q7 and Q11 untimed: all full marks,
98/100. Q4 worked on the second meeting with the `Retain` trap, the difference
being that the object was read back after patching. Drill 08 environment then torn
down.

**2026-08-18** — Finished the security module: authentication, kubeconfig,
API groups, authorization modes, RBAC, ClusterRoles, admission controllers, API
versions and deprecation policy, CRDs, custom controllers and operators.

**2026-08-19** — Test 09 (Security: RBAC, CRDs, Admission & Quotas):
**82/100 by reconstruction**, 19 of 20 attempted in ~61 minutes. See ‖ above — the
grader's 18 is an artefact of Claude wiping the namespaces mid-sitting, not a
result. **RBAC section perfect: Q1-Q8, 40/40.** Q10's from-scratch CRD 7/7
including the schema bounds. Two firsts: the wrong-namespace error was
**self-caught in-flight** on Q17, and a failed permission check drove a real
diagnosis on Q1 (immutable `roleRef` → `replace --force`). Losses were Q12
(7, repair abandoned after confirming the symptom five ways without reading the
object), Q20 (4, docs resource values copied verbatim), Q19 (3, `app: taregt`
typo left in the selector) and Q15 (3, deliberately skipped). Weakness #1
(namespaces) is now closed; the new #1 is the diagnostic loop stopping one step
short — see weakness #0.

**Process failure to not repeat:** never run `cleanup.sh`, `setup.sh` or
`solutions.sh` once a sitting has started. Fixing a grader bug mid-test cost a
whole paper's live state. Also fixed that day: test 09 Q12's grader check only
asserted the `Established` condition, so a CRD with `served: false` passed it.

**2026-08-20** — Helm section finished (package-manager concepts, charts,
templates + values.yaml, `repo add/list`, `search hub` vs `search repo`, `install`,
`list`, `upgrade`, `rollback`, `uninstall`, `pull --untar`, installing from a local
directory). Test 10 built over it: 10 weighted scenarios, exam-style, 100 points in
60 minutes.

Three environment facts found while building it, all worth knowing:

- **Helm 4.2.2 is installed here; the exam uses Helm 3.** Every command in the test
  behaves the same on both.
- **Bitnami images no longer pull.** Bitnami moved to a paid registry in 2025;
  `docker.io/bitnami/apache:*` 404s and old tags now live under `bitnamilegacy/`.
  The chart metadata is still public, so test 10 uses the Bitnami repo for
  search/pull questions but installs from a local chart shipped in the repo. The
  course lab's `helm install bitnami/...` steps will fail today.
- **Nine work Helm repos are configured on this machine** (gitlab, traefik, cnpg,
  jetstack and others). Test 10's cleanup only removes `bitnami`, and only if the
  test added it.

Test 10 validated end to end: 0/100 on a fresh environment, 100/100 from the answer
key. The `helm upgrade` values-reset trap in Q6 was confirmed empirically —
`helm upgrade --set replicaCount=5` on a release installed with
`--set service.type=NodePort --set service.nodePort=30099` silently reverted the
Service to ClusterIP with no node port. Values do **not** carry over without
`--reuse-values` or repeating them.

**2026-08-20 (evening)** — Test 10 (Helm): **84/100**, all 10 attempted, finished
in 22 minutes with **37:39 unused**. Q1, Q3, Q5, Q8, Q9, Q10 full marks. Helm
mechanics are solid: `repo add`, `search repo`, `pull --untar`, install with
`--set`, install with `-f`, two independent releases side by side, diagnosing an
ImagePullBackOff release and repairing it *through Helm* so the stored manifest was
fixed rather than the live object, a clean `uninstall` that left nothing behind and
did not disturb the neighbouring release, and a correct `rollback`.

Losses: Q2 (6, dumped the whole values file instead of the two values asked for),
Q6 (4, the `helm upgrade` values-reset rule), Q4 (3, wrote `anvil-message` where
the question said `anvil-build`) and Q7 (3, never wrote the revision file).

**The one real knowledge gap, and it is worth remembering:**
`helm upgrade release chart --set replicaCount=5` does **not** keep the values from
the previous install. It starts from the chart defaults plus whatever `--set` gives
it. Revision 2 here recorded `replicaCount: 5` as the only user value, so the
Service silently dropped from NodePort/30080 back to ClusterIP with no node port.
Either repeat every value you still want, or pass **`--reuse-values`**. This was
confirmed on a throwaway release before the test was published, so it is a real
Helm behaviour and not a grader artefact.

**2026-08-24** — **Cluster died and was rebuilt from scratch.** Root cause worth
remembering: kind gave the containers new IPs after a restart, but etcd peer URLs
are baked in at bootstrap. cp2 was still dialling `172.18.0.9` for cp1, which had
moved to `172.18.0.8`. Both members crash-looped at attempt 127, each getting only
its own prevote:

```
has received 1 MsgPreVoteResp votes and 0 vote rejections
error creating storage factory: context deadline exceeded
```

**The kind config uses 2 control planes, which means a 2-member etcd and a quorum
of 2 — strictly worse than a single control plane, because any one failure takes
the cluster down and membership cannot be repaired without quorum.** Nidhey chose
to rebuild on the same config rather than change it; noted and respected. Expect
this again after the next Docker or Colima restart. The fix, when wanted, is 1 or
3 control planes.

Rebuilt clean. `fs.inotify.max_user_instances=8192` survived in the Colima VM, so
no host work was needed. Colour-node fixture restored. **ingress-nginx is NOT
reinstalled** — test 06 needs it for traffic-routed Ingress questions.

Also added `cluster/setup.sh` and `cluster/teardown.sh` to the repo. Teardown
prunes the `ckad-*` contexts too; `kind delete cluster` leaves them pointing at a
dead cluster and eleven had piled up.

**2026-08-24 (later)** — Kustomize section finished (base/overlay model,
`kustomization.yaml`, transformers, image transformer, JSON 6902 vs strategic
merge patches, list operations, overlays, components). Test 11 built over it:
10 weighted scenarios, exam-style, validated 0/100 fresh and 100/100 from the
answer key. Cheat sheet gained a full Kustomize section.

Environment facts found while building it:

- **Kustomize v5.8.1 ships inside kubectl.** No separate binary installed and none
  needed.
- **The course's syntax is deprecated but still works.** `commonLabels` (now
  `labels:`) and `bases` (now `resources:`) both render fine and print a warning.
  Test 11 grades rendered output, so either spelling scores full marks.
- `newTag: 2.4` unquoted fails with `cannot unmarshal number into Go struct field
  Image`. Quote it.

**2026-08-25** — Test 11 (Kustomize): **92/100**, 9 of 9 attempted in ~41 minutes
with 18:35 left, **100% accuracy on attempted work**. Full marks on writing a
kustomization from scratch, all four common transformers, nesting a kustomization
per subdirectory, scoping the image transformer to one directory so `redis` stayed
untouched, a JSON 6902 scalar replace, a strategic-merge patch from its own file
matched by container name, removing a list item by index while the two earlier
patches stayed in effect, base plus dev/prod overlays, and diagnosing a
kustomization that named a file which did not exist on disk.

Notable: Q8's prod ConfigMap was built with **`configMapGenerator`** rather than a
plain YAML file — a more idiomatic route than the one the question suggested, and
beyond what the course taught. My grader demanded the literal name
`prod-prod-flags` and the generator's content hash made it
`prod-prod-flags-794444tth4`, so it wrongly scored 0. **Seventh grader
over-specification.** Fixed to match on prefix; the question now states both routes
score equally. The 92 is after that correction; the raw grader said 88.

Q10 (Components) skipped on purpose — flagged in the question as outside the
curriculum. Correct call with 18 minutes spare.

**2026-08-27** — **Syllabus closed.** Studied container images (Dockerfile
instructions, multi-stage, ENTRYPOINT/CMD to command/args, imagePullPolicy defaults,
registry secrets) and Pod Security Admission (three levels, three modes, namespace
labels, version pinning). Cheat sheet gained expanded sections for both, plus a
**Time management** section and a **Which docs site for what** section.

Test 12 (Images & PSA): **75/100**, 10 of 11 attempted in 57 minutes. Full marks on
every image question and every PSA question — Q1 multi-stage build with `/build`
stripped and UID 1000, Q2 the `args`-without-`command` asymmetry, Q6 all four
`restricted` settings with the pod actually Running, Q7 finding the admission
rejection on the **ReplicaSet** rather than the Deployment, Q11 RBAC with passing
negative checks. **No knowledge gap in either new topic.**

Losses: Q5 (8, labels applied to `harbor` instead of `bulwark` — weakness #1, now
reopened), Q9 (9, wrote `labels:` with map syntax when that field takes a **list**;
`commonLabels:` is the map form, and the error said `of type []types.Label`),
Q10 (8, never reached — out of time).

Verified empirically while building the test: PSA `enforce=restricted` rejects a
bare pod with a message naming all four missing settings; a non-compliant Deployment
is accepted while its ReplicaSet reports `FailedCreate` carrying the same message; a
compliant `nginxinc/nginx-unprivileged` pod runs; a busybox multi-stage build takes
~9s and `kind load` ~1s across all 7 nodes.

**2026-08-27 (evening)** — **Test 13, full exam simulation: 95/100.** First paper
covering all five domains with the topic of each task unknown until read, and the
first written to real CKAD conventions — `Task weight` headers, team narrative then
imperatives, and **no indication of what is graded**.

Perfect scores in three domains:

| Domain | Weight | Scored |
|---|---|---|
| Application Design and Build | 20 | **20** |
| Application Deployment | 20 | 20 (Q5 credited) |
| Observability and Maintenance | 15 | **15** |
| Environment, Configuration and Security | 25 | **25** |
| Services and Networking | 20 | **15** |

Both genuine losses were in Services and Networking, and both were verification
failures rather than knowledge gaps:

- **Q15 (3 pts)** — the Service had `port 8080 -> targetPort 8080` while the pods
  listen on 80. The selector was fixed, so `get endpoints` showed 2 and looked
  healthy. **Endpoints are derived from the selector, not from port reachability.**
  The task explicitly said to test with `wget`; the Service was edited three times
  and traffic was never sent once. Weakness #0 exactly: the check that would have
  failed was the one not run.
- **Q17 (2 pts)** — `spec.ingressClassName` left empty, though the task stated the
  cluster's controller is not the default.

Research done the same day, verified against Linux Foundation documentation, and
worth carrying into the real exam:

- **15-20 tasks, 2 hours, 66% to pass, Kubernetes v1.35.**
- **`jq` is NOT on the exam hosts.** Documented tooling is `kubectl` (with a `k`
  alias and completion), `yq`, `curl`, `wget`, `man`.
- **Context switching is now `ssh <host>`, not `kubectl config use-context`.** Each
  task names a host; you SSH in, work, `exit` back to `base`, which has no tools.
- Docs allowed: `kubernetes.io/docs` and subdomains, `kubernetes.io/blog`,
  `helm.sh/docs`, plus links in a per-task Quick Reference box. **Gateway API is CKA
  only.**
- CKAD has **no Troubleshooting domain**; cluster-repair questions are CKA. CKAD
  debugging is application-level only.

**Timing on test 13 was the standout.** 17 tasks in **72 minutes** against a
self-imposed 90, finishing 18 early — and the real exam allows 120 for this many
tasks. That is roughly 4.2 min/task against an allowance of ~7. Time pressure,
which sank test 12 (Q10 never reached), is no longer the binding constraint.

**Two lab bugs found and fixed on 2026-08-27, both the same class:** a task
naming something the environment cannot provide, which is indistinguishable from
a wrong answer.

- Docker Hub was unreachable all evening (`i/o timeout` to auth.docker.io).
  Test 13 Q5 needed an image that was not cached, so the task was unwinnable and
  the 5 marks were credited back.
- Test 14 Q19 depended on `kubectl logs --previous`, which stops working once
  containerd reclaims the dead container. `lastState.terminated` survives but the
  log does not.

`tests/lib.sh` now has `require_images` / `require_images_available`, called from
both papers' `setup.sh`, which refuses to hand over a test whose images are
neither cached on any node nor pullable. **Two duplicate implementations of this
existed briefly**; the earlier one only checked `${CLUSTER_NAME}-worker` (which
caches nothing) and hardcoded `docker.io/library/`, so it would have hard-failed
test 13's setup and never matched `nginxinc/*`. Consolidated into one.

**Open question, unresolved:** Nidhey read test 13 Q5 as `nginx:1.26` and has a
screenshot; the file on disk byte-checks as `nginx:1.24`, `1.26` appears nowhere
in the repo, and the README mtime (14:51) predates their 15:30 start. The
plausible explanation is a stale editor buffer — test 13 was created ~13:52 and
its README rewritten at 14:51. Either way the task was unwinnable, so it did not
change the score. Worth watching if it recurs.

**Test 14 now exists: `tests/14-mock-exam-20q`, 20 tasks, 120 minutes, seeded and
unsat.** Twenty is the real question count, and per-domain points match the
published weights exactly. Grader validated in both directions: answer key
100/100 with zero failed checks, fresh cluster 1/100. Building it surfaced four
**vacuous-truth** grader bugs worth remembering, since the same shapes exist
elsewhere: jq's `all()` is true over an empty array (a missing Kustomize overlay
scored full marks); a ServiceAccount that does not exist "cannot" do anything, so
a negative RBAC check passed; with no NetworkPolicy everything is reachable, so a
positive traffic check passed; and a rollback check could not distinguish "rolled
back" from "never touched" because the seed already had the target image.

Test 14's questions were also rewritten once for register: the first draft
disclosed what the grader checked three times, explained its own reasoning, and
bolded every value. All removed. Its headers now match test 13's
`Use context:` / `#### Task` form, which is closer to killer.sh than the
one-line variant test 05 uses.

**2026-08-28** — **Nine full-length mock exams now exist**: 13, 14, and new papers
15-21 ("mock exam A" to "G"). Each is 20 tasks, 120 minutes, pass 66, weights
summing to 100 with per-domain totals matching the published curriculum split
exactly. All follow real CKAD conventions - `Task weight` header, business context
then exhaustive explicit requirements, three "investigate and fix" tasks per paper
with the fault never named, and **no indication of what is graded**. Competencies
are spread so the seven do not repeat each other: between them they cover the
downward API, Indexed Jobs, native sidecars, adapter and ambassador patterns,
DaemonSet update strategies, quota scopes, `sessionAffinity`, `ipBlock` egress,
projected volumes, `seccompProfile`, ephemeral-container debugging, ExternalName,
hand-written Endpoints and Ingress default backends.

Every paper validated end to end on a live cluster: **0/100 fresh, 100/100 from its
own answer key.**

**The cluster was destroyed and rebuilt mid-work.** Installing the CK-X simulator
removed the `ckad-lab` kind cluster entirely, taking tests 13 and 14's seeded state
with it. Rebuilt from `cluster/setup.sh`. Scores were unaffected because this
tracker lives outside the cluster and outside git. Nidhey chose to run CK-X and
ckad-lab side by side on the same 8-CPU VM.

**Five bugs the rebuild exposed, every one of which would have cost real marks:**

1. **`kind load docker-image` is unusable on arm64.** It runs `ctr images import
   --all-platforms`; a single-arch pull has no blobs for the other platforms in the
   manifest list, so it dies with `content digest ...: not found`. Replaced with a
   per-node `ctr import` without that flag.
2. **`kind get nodes` returns the HAProxy load balancer**, which has no `ctr` or
   `crictl`. It returned 127 and failed every image check regardless of reality.
3. **`edge` was shared by tests 05 and 06, `atlas` by tests 02 and 11**, so one
   test's cleanup deleted the other's fixtures. Renamed to `lagoon` and `cobalt`;
   all 108 namespaces are now unique. This had been noted in this file weeks ago
   and never actioned.
4. **`grep -m1` under `set -o pipefail` reports failure even on success**, because
   exiting early SIGPIPEs the upstream command. This silently emptied an answer
   file in a solutions script.
5. A `stat` without `-L` read a Secret volume's **symlink** mode (777) rather than
   the target's (400), and would have docked a correct answer.

**Nothing is seeded.** The cluster is clean; seed a paper when you want to sit it.

**Next — the syllabus is complete, so what remains is practice, not study:**
1. **Sit the mocks.** Seven still unseen (15-21). Two hours each, real conditions.
   This is the whole remaining programme.
1b. **Spend the spare time on identifiers, not on more building.** Tests 13 and 14
   both finished early and both lost points to names and values rather than
   concepts. A five-minute pass re-reading every object name, namespace and number
   against the question text would have been worth 12 points on test 14 alone.
2. **Test 03** — a clean read on multi-container/observability, where the only
   uncontaminated number is a stale 67 off a miscalibrated clock.
3. Redo test 12 Q5, Q9 and Q10 untimed — all three are one-line fixes.
4. **Drill the Q15 failure mode specifically**: build a Service whose port differs
   from its pods' container port, then prove reachability with `wget` rather than
   `get endpoints`. Endpoints derive from the selector and look healthy while the
   ports are wrong. This is the one weakness that survived test 13.

**Book the exam once two or three mocks come in above 80 cold.** Test 13 was 95
first time, so the bar is already being cleared; the remaining papers buy
confidence that it was not a one-off.
