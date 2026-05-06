# Insight Memory Report

> Companion package: `IG-Benchmarks` at `src/IG-Benchmarks/` (specifically
> `IGMemBench`).
> Raw data: `/tmp/insight-mem.csv` produced by `IGMemBench runAllAndExport`.
> Performance findings live in [`REPORT.md`](./REPORT.md).

---

## 1. Headline

**Insight does not leak.** 1000 instrument/uninstrument cycles per
scenario × workload (9 cells, 9000 cycles total) leave **zero retained
instances** of any tracked Insight class after a forced full GC. A single
`profileOn:` pipeline likewise leaves zero retentions.

This is the only reliably-measurable memory question in this bench. We
attempted to measure transient allocation (GC pressure per profileOn run)
but had to abandon the signal — see §3.

---

## 2. Methodology

### 2.1 Tools

`IGMemBench` uses two Pharo APIs:

- `Smalltalk garbageCollect` — forces a full GC before each snapshot.
- `<Class> instanceCount` — counts live instances of a class.

A third API (`Smalltalk vm parameterAt: 3` for used-memory bytes) was
investigated and dropped — see §3.

API availability was probed before writing the bench; the two we kept
work in Pharo 64-bit 13.x.

### 2.2 Two experiments

**Leak test (long-term retention).** For each `(scenario, workload)`
cell:
1. Run 5 untimed warmup cycles (settle one-time class init).
2. Force a full GC, snapshot live instance counts.
3. Run N=1000 cycles of `instrumentMethod: → uninstrumentMethod:`.
4. Force another full GC, snapshot again.
5. Per-class delta. Zero means no leak.

**Allocation test (single-run retention).** For each cell:
1. Run one warmup `profileOn:`.
2. Force GC, snapshot.
3. Run one measured `profileOn:`.
4. Force GC, snapshot.
5. Per-class delta. Zero means the pipeline cleans up after itself.

This is much weaker than "does one profileOn cause memory churn during
the run" — see §3 — but it does answer "does one profileOn leave anything
alive?".

### 2.3 Scope

- **Workloads:** `mediumMethod`, `heavyMethod`, `tightLoopHeavy:`. Drops
  `tinyMethod` (fixed costs dominate) and inner-loop workloads where
  R1's reach limitation makes a fair comparison impossible.
- **Scenarios:** B0 (allocation-test only), C1, A1, R1.
- **Tracked classes:** `IGInstrumentation`, `IGCounter`, `IGCollector`,
  `IGAfterStatementHook`, `IGBeforeStatementHook`,
  `IGStatementResultReification`, `IGInstrumentationContext`,
  `OCMethodNode`. The first six catch leaks of Insight's own
  bookkeeping; `OCMethodNode` catches leaked rewritten ASTs.

### 2.4 Run environment

- Pharo 64-bit 13.x
- Image well-warmed (~1.2 GB used at run start)
- 21 result rows, total wall time ~1–2 minutes

---

## 3. Why we don't report transient allocation

We tried two approaches and abandoned both.

**Approach 1 (post-GC bytes only).** Read `Smalltalk vm parameterAt: 3`
*after* forcing a GC, both before and after the workload. The delta
should approximate retention. **Result: always zero**, including the B0
control which definitely allocates *something* during a 30 000-call loop.
Conclusion: post-GC reads only capture retention; transient allocation
is wiped by the forced GC before the second read.

**Approach 2 (pre-GC and post-GC bytes).** Read `parameterAt: 3` *before*
forcing a GC for the high-water mark, *after* for retention. The pre-GC
delta should approximate transient allocation. **Result: still always
zero** for both pre-GC and post-GC reads.

The reason: Pharo's nursery scavenges run automatically and frequently
during normal allocation. A `30000 timesRepeat: [...]` block allocates
entirely in the nursery; the scavenge collects it transparently before
the bench reads the counter. Even pre-GC reads see the same value as
post-GC reads, because the implicit scavenges already happened.

To genuinely measure transient allocation we would need either:
- A VM counter that includes scavenge-recovered bytes (a "total bytes
  ever allocated" counter, not "current heap occupancy").
- An external profiler that hooks the allocation primitives.
- Object-allocation instrumentation that's inevitably observer-bias-prone.

None of these were within scope. **The bench now reports only the
retention signal**, which is what `instanceCount` provides directly and
correctly.

---

## 4. Results

### 4.1 Leak test (1000 cycles per cell)

| Scenario | Workload | Cycles | deltaGCCount | Non-zero retentions |
|---|---|---|---|---|
| C1 | `mediumMethod`     | 1000 | 1 | **none** |
| C1 | `heavyMethod`      | 1000 | 1 | **none** |
| C1 | `tightLoopHeavy:`  | 1000 | 1 | **none** |
| A1 | `mediumMethod`     | 1000 | 1 | **none** |
| A1 | `heavyMethod`      | 1000 | 1 | **none** |
| A1 | `tightLoopHeavy:`  | 1000 | 1 | **none** |
| R1 | `mediumMethod`     | 1000 | 1 | **none** |
| R1 | `heavyMethod`      | 1000 | 1 | **none** |
| R1 | `tightLoopHeavy:`  | 1000 | 1 | **none** |

**`deltaGCCount = 1` everywhere is exactly the manual GC fired inside
`takeSnapshot` for the second snapshot.** No automatic full GCs happened
during the 1000-cycle window — Insight's allocation pressure during
instrument/uninstrument is low enough to fit in the nursery without
triggering full collections.

The "non-zero retentions" column is the actual leak signal:
per-tracked-class instance count delta. Zero across all cells means none
of `IGInstrumentation`, `IGCounter`, `IGCollector`, the hook classes,
`IGStatementResultReification`, `IGInstrumentationContext`, or
`OCMethodNode` have a single instance left over after 1000 cycles.

### 4.2 Allocation test (one `profileOn:` per cell)

| Scenario | Workload | deltaGCCount | Non-zero retentions |
|---|---|---|---|
| B0 | `mediumMethod`     | 1 | none |
| B0 | `heavyMethod`      | 1 | none |
| B0 | `tightLoopHeavy:`  | 1 | none |
| C1 | `mediumMethod`     | 1 | none |
| C1 | `heavyMethod`      | 1 | none |
| C1 | `tightLoopHeavy:`  | 1 | none |
| A1 | `mediumMethod`     | 1 | none |
| A1 | `heavyMethod`      | 1 | none |
| A1 | `tightLoopHeavy:`  | 1 | none |
| R1 | `mediumMethod`     | 1 | none |
| R1 | `heavyMethod`      | 1 | none |
| R1 | `tightLoopHeavy:`  | 1 | none |

A single `profileOn:` pipeline (build profiler, instrument target, run
workload, build coverage result, restore method) leaves zero retentions.

---

## 5. What the leak signal actually tells us

### 5.1 No retained instances after teardown

After 1000 instrument/uninstrument cycles on the largest workload,
the live instance count of every tracked class is unchanged. Specifically:

- `IGInstrumentation`, `IGCounter`, `IGCollector`, the hook classes,
  `IGStatementResultReification`, `IGInstrumentationContext` —
  Insight's own bookkeeping cleans up.
- `OCMethodNode` — every `instrumentMethod:` call builds a new
  instrumented AST internally (`generateInstrumentedAST:`), and that AST
  is owned by the new `CompiledMethod`. When `uninstrumentMethod:` swaps
  the original method back into the methodDict, the rewritten method
  becomes unreachable and is collected. **No method-AST leak.**

### 5.2 What this rules out

- "Test suites that profile thousands of methods will eventually OOM
  the image because each cycle leaks a few KB" — **no, they won't.**
- "Long-running CI jobs that re-instrument the same method many times
  build up garbage" — **no, they don't.**
- "A single `profileOn:` retains internal state between calls" —
  **no, it doesn't.**

### 5.3 What this does NOT rule out

- **Transient allocation pressure** — see §3. We can't measure GC churn
  during steady-state with this bench.
- **Crash-during-instrumentation leaks.** If `instrumentMethod:` raises
  partway through (e.g. a malformed AST that `doSemanticAnalysis`
  rejects), `uninstrumentMethod:` is never called and whatever was
  partially installed survives. This bench only covers the happy path.
- **Per-firing allocations during steady-state.** The leak test measures
  *survives across cycles*, not *allocated during one call*. See §6 for
  qualitative observations from the perf bench.
- **Collector growth at runtime.** This is a real concern, separately
  documented — see §6 and `REPORT.md` §4.6.

---

## 6. Steady-state allocation pressure (qualitative)

This bench can't measure transient allocation directly (§3), but
`REPORT.md` §2.3 has indirect evidence about which scenarios cause GC
pressure:

- On `tightLoopHeavy:` with A1, the steady-state min-to-max spread is
  856 825 µs → 3 686 179 µs (4.3×). On the same workload with R1, it's
  3 689 470 µs → 3 850 126 µs (1.04× — basically flat).
- Across 20 measured iterations, A1 accumulates ~10M entries in the
  collector. Each entry is an AST node *reference*, which is small —
  but the **reachability graph** behind those references retains every
  parent in the AST, every literal, etc. The GC has to walk it.

So the qualitative answer to "does R1 allocate more than A1?" is:
**not really, in fact slightly less when you measure stability**,
because R1 captures values (small integers in our test) that the GC
treats as cheap, while A1 captures AST node references whose retained
graph is much bigger.

Practical takeaway: **`IGCollector` accumulates unboundedly** and is the
single biggest memory-shaped concern in the framework. Not a leak, but a
usability footgun.

---

## 7. Improvement focus points (memory-side)

The headline finding (no leaks) means there's no bug to fix here. The
secondary findings point in two directions:

| # | Change | Why |
|---|---|---|
| M1 | **Bound `IGCollector`** with a `maxSize:` mode (ring buffer or hard cap with optional drop policy). Currently unbounded. | Already #6 in `REPORT.md`§5. The bench on `tightLoopHeavy:` indirectly shows ~10M entries accumulating; users will hit GC pressure long before they hit a leak. |
| M2 | **Add an exception-safety wrapper around `instrumentMethod:`** that calls `uninstrumentMethod:` on failure, ensuring the method dict is restored even if rewriting raises. | Not measured here — purely defensive. The leak test only covers the happy path. |
| M3 | **Find a way to measure transient allocation** in Pharo (see §3). Future work. Would need a VM counter that survives nursery scavenges, or external profiling. | Currently we cannot say whether `profileOn:` causes 1 KB or 10 MB of GC churn per call. Both are plausible from the per-firing data. |

---

## 8. Reproduction

```smalltalk
"In a Pharo 13 image with Insight + IG-Benchmarks loaded:"
IGMemBench runAllAndExport.
"Then read /tmp/insight-mem.csv or the Transcript output."
```

Total wall time: ≈ 1–2 minutes. To stress-test more aggressively, raise
`IGMemBench class >> defaultLeakCycles` from 1000 to 10000+.

---

## 9. Summary

| Question | Answer |
|---|---|
| Does Insight leak across instrument/uninstrument cycles? | **No.** 1000 cycles, 0 retained instances of any tracked class. |
| Does the rewritten AST survive uninstrument? | **No.** OCMethodNode count unchanged. |
| Does a single `profileOn:` retain anything? | **No.** All counts unchanged. |
| Can we measure transient (per-call) allocation? | **No** — Pharo's nursery scavenges hide the signal. See §3. |
| Should I worry about memory in production? | **Only if you use `IGCollector` on hot paths without a bound.** That's a usability gap (§6), not a leak. See M1. |
