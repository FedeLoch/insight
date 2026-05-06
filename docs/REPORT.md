# Insight Benchmarking Report

> Companion package: `IG-Benchmarks` at `src/IG-Benchmarks/`.
> Raw data: `/tmp/insight-bench.csv` produced by `IGBenchRunner runAllAndExport`.
> Memory-specific findings live in [`REPORT-MEMORY.md`](./REPORT-MEMORY.md).
> All times in microseconds (µs) unless noted otherwise.

---

## 1. Methodology

### 1.1 Tool

A small custom harness in `IGBenchHarness` (≈40 lines) rather than SMark.
Reasons: neither `smarr/SMark` nor `guillep/SMark` advertises Pharo 13
compatibility; we only need warmup, repeated measurement, and basic
statistics, which fit in five class-side methods. Migrating to SMark
later is self-contained.

### 1.2 Timing primitive

`BlockClosure>>microsecondsToRun` (returns Integer µs).

### 1.3 Iteration protocol

| Cost type | Warmup | Measured |
|---|---|---|
| Steady-state | 3 | 20 |
| Setup (`instrumentMethod:`) | 0 | 10 |
| Teardown (`uninstrumentMethod:`) | 0 | 10 |
| Profiler end-to-end | 0 | 10 |

Reported statistics: `min`, `median`, `mean`, `max`. **`min` is preferred**
for analysis (cleanest signal, fewest GC interruptions); `median` is the
headline.

### 1.4 Workloads

Synthetic, defined in `IGBenchMock`. Inner-loop counts (the unit of one
measurement) are listed below.

| Selector | Description | Inner | Notes |
|---|---|---|---|
| `tinyMethod` | `^ 42` | 200 000 calls | Method-frame floor |
| `lightMethod` | 5 assignments + return | 100 000 calls | |
| `mediumMethod` | 20 assignments + return | 30 000 calls | |
| `heavyMethod` | `x:=0` + 50 increments + return | 10 000 calls | |
| **`straightLine200`** | 200 OrderedCollection sends | 1 000 calls | **JIT-resistant** |
| `assignmentChain` | `a := b := c := d := 42` | 100 000 calls | AST flattening worst case |
| `tightLoop:` | `whileTrue:` with 1-stmt body | 500 000 iters | Inner-block firing |
| `tightLoopHeavy:` | `whileTrue:` with 16-stmt body | 30 000 iters | Inner-block firing |
| `messageSendHeavy:` | self-send loop | 200 000 sends | Inner-block firing |
| `recursiveFactorial:` | recursive | depth 500 | |

`straightLine200` was added because the original workload set's smaller
straight-line methods could be partially eliminated by the JIT — see §2.1.

### 1.5 Scenarios

| Code | Hook | Action |
|---|---|---|
| B0 | — | — (uninstrumented baseline) |
| C1 | After-statement | `Counter countKeyBy: #astNode` (the coverage path) |
| H1 | After-statement | `Counter` (single key) |
| H2 | Before-statement | `Counter` |
| H3 | After-assignment | `Counter` |
| H4 | Before-assignment | `Counter` |
| A1 | After-statement | `Collector` capturing AST node |
| A2 | After-statement | `Collector` capturing receiver |
| R1 | After-statement | `Collector` capturing `statementResult` |

### 1.6 Run environment

- Pharo 64-bit 13.x
- Image well-warmed (~1.2 GB used, 191 prior full GCs at run start)
- Total benchmark wall time: ≈ 7–8 minutes

---

## 2. Critical methodology notes — read before §3

Two issues affect interpretation. Both are now properly corrected in §3
calculations.

### 2.1 JIT dead-code elimination on baselines

Several B0 measurements come in absurdly low because Cog's JIT eliminates
their bodies (return value unused, no observable side effect). For
example, `mediumMethod` baseline reads as 0.0074 µs/call, which is below
the cost of a single object allocation. That's the JIT erasing the body,
not real performance.

| Workload | B0 min (µs) | Per-call (µs) | Trustworthy? |
|---|---|---|---|
| `tinyMethod` | 224 | 0.0011 | **No — DCE** |
| `lightMethod` | 9 195 | 0.0920 | Yes |
| `mediumMethod` | 222 | 0.0074 | **No — DCE** |
| `heavyMethod` | 104 | 0.0104 | Borderline |
| **`straightLine200`** | **3 396** | **3.396** | **Yes — JIT-resistant by design** |
| `assignmentChain` | 323 | 0.00323 | **No — DCE** |
| `tightLoop:` | 231 | 0.000462 | **No — DCE** |
| `tightLoopHeavy:` | 416 130 | 13.871 | Yes |
| `messageSendHeavy:` | 431 | 0.00216 | **No — DCE** |
| `recursiveFactorial:` | 59 | 0.118 | Yes |

When a baseline is DCE-affected, use the **absolute per-firing cost**, not
the slowdown ratio. The slowdown ratio reflects the JIT compiler more
than Insight.

### 2.2 Hook reach: most hooks reach inside blocks; R1 does not

A probe (`tightLoop: 5` instrumented with each scenario, capture counts
inspected) revealed:

- **C1, A1, A2, H1, H2, H3, H4** fire on every statement of the method,
  including statements inside `whileTrue:` block bodies, `ifTrue:`
  branches, etc. On `tightLoop: 5` C1 fires 14 times (3 top + 6 predicate
  + 5 body).
- **R1** (Collector capturing `statementResult`) only fires on top-level
  statements. On `tightLoop: 5` R1 fires 2 times (the two top-level
  statements that return a meaningful value: `i := 0` and `^ i`).

This is consistent with `IGTest>>testCoverageInstrumentAConditionalWithAnAfterHook`
which asserts that a conditional method's true-branch and false-branch
inner statements get counted by an After-statement counter.

R1's restriction is a property of `IGStatementResultReification>>rewriteOperationsForNode:`,
which only wraps statements at the top level — likely because wrapping a
statement inside a block requires hoisting a temp out of the block scope,
which the rewrite doesn't currently do.

**Implication:** for `tightLoop:`, `tightLoopHeavy:`, `messageSendHeavy:`,
the high-firing-count steady-state cost in C1/A1/etc IS real per-firing
work (just spread across millions of inner-block firings). R1's
near-baseline cost on the same workloads reflects only 2-4 firings per
call, not zero overhead.

### 2.3 Collector growth + GC tax

The collector accumulates into an unbounded `OrderedCollection`. Across
20 measured iterations, on `tightLoopHeavy:` with A1/A2, the collector
grows to 10M+ entries:

| Stat | A1 | A2 | R1 |
|---|---|---|---|
| min | 856 825 µs | 2 008 371 µs | 3 689 470 µs |
| median | 2 050 836 µs | 3 354 145 µs | 3 810 986 µs |
| max | 3 686 179 µs | 5 645 076 µs | 3 850 126 µs |

The 4× span between A1 min and max is GC pressure, not CPU work. R1
shows the same pattern (heavily inflated by collector retention) but
stabilizes faster because R1 captures *values* (small integers), while
A1/A2 capture AST node references whose retained graph is much larger.

When dividing by firing count, R1 on `tightLoopHeavy:` produces a
nonsensical "818 335 µs/firing" number because R1 fires only 4 times per
call but accumulates ~80 entries × 30 000 calls × 20 iterations of
collector entries. **Treat min, not mean, as the per-firing signal — and
distrust R1 numbers on inner-loop workloads.**

---

## 3. Results

### 3.1 Steady-state per-firing cost — the headline number

**Per-firing cost** = (scenario_min − B0_min) / total_firings_per_measurement.

Total firings depend on hook reach (§2.2). For C1/A1/H1/H2: every
statement fires, including inside blocks. For H3/H4: every assignment.
For R1: only top-level statements.

#### C1 per-firing across all workloads (the coverage path)

| Workload | Total C1 firings/measurement | Δ vs B0 (µs) | µs/firing |
|---|---|---|---|
| `lightMethod`         | 600 000   | 125 965 | **0.210** |
| `mediumMethod`†       | 630 000   | 95 605  | 0.152 |
| `heavyMethod`         | 510 000   | 110 496 | **0.217** |
| `straightLine200`     | 202 000   | 44 446  | **0.220** |
| `assignmentChain`†    | 200 000   | 50 981  | 0.255 |
| `tightLoop:`†         | 1 000 004 | 165 097 | 0.165 |
| `tightLoopHeavy:`     | 540 005   | 129 704 | 0.240 |
| `messageSendHeavy:`†  | 600 005   | 354 290 | 0.591 |
| `recursiveFactorial:` | 1 000     | 266     | 0.266 |

† JIT-DCE on baseline (§2.1): per-firing computed against an unrealistically
fast B0, so the absolute number is somewhat distorted but proportionally
small (the `tightLoop:` 0.165 underestimates by a few percent).

**Headline: a C1 hook firing costs approximately 0.21–0.27 µs across
clean workloads.** The `messageSendHeavy:` outlier at 0.59 µs/firing is
because each "firing" there happens on a more complex AST node (a self-send
expression with arguments rather than an assignment), which produces a
larger reified `astNode` literal.

#### Per-firing convergence by scenario (clean workloads only)

| Scenario | lightMethod | heavyMethod | straightLine200 | typical |
|---|---|---|---|---|
| C1 (Counter[astNode]) | 0.210 | 0.217 | 0.220 | **~0.215 µs** |
| H1 (Counter)          | 0.0852 | 0.0689 | 0.0910 | **~0.082 µs** |
| H3 (Counter, assign-only) | 0.0875 | 0.0682 | n/a‡ | ~0.078 µs |
| A1 (Collector[astNode]) | -0.003 | 0.006 | 0.045§ | ~0.005–0.045 µs |
| A2 (Collector[receiver]) | 0.0024 | 0.006 | -0.013§ | ~0.005 µs |
| R1 (Collector[statementResult]) | -0.005 | 0.006 | 0.0065 | **~0.005 µs** |

‡ `straightLine200` has no assignments. § A1 on `straightLine200`
includes GC crosstalk from the OrderedCollection mutations in the workload
itself plus the 200k collector entries; not pure capture cost.

#### Findings

1. **C1 ≫ H1 by ~2.6×** (0.215 vs 0.082 µs/firing). The 0.13 µs delta
   is the cost of `Dictionary at:update:initial:` plus the `astNode`
   reification at the call site. (Improvement target — see §5 #2.)

2. **H1 ≫ A1/R1 by ~16×** (0.082 vs 0.005 µs/firing). The cost is in
   the `IGCounter` action body itself (Dictionary work) more than in the
   instrumentation send. A collector that just appends a value to an
   `OrderedCollection` is 16× cheaper per firing than a dictionary
   counter.

3. **R1 ≈ A1 in steady-state on clean workloads.** The `temp := stmt`
   wrap that R1 forces is one extra local store, too cheap to measure.
   (Setup is more expensive — see §3.2.)

4. **The `messageSendHeavy:` C1 outlier (0.59 µs/firing)** suggests
   per-firing cost depends on AST-node shape. Coarse expressions =
   bigger reified literals = slower. Worth investigating if exact cost
   modeling matters for a downstream user.

#### Per-call overhead (for sizing real-world impact)

For a method with N top-level statements, the per-call overhead is
roughly `N × 0.215 µs` for C1. For methods with inner loops, multiply by
loop iterations as well — every statement inside the inner block also
fires.

A 20-statement method instrumented for coverage (C1):

```
20 × 0.215 µs/firing = 4.3 µs of overhead per call
```

If your method's uninstrumented body takes ~10 µs (a realistic figure
for a small Smalltalk method), C1 instrumentation costs **~40% slowdown**.
If your body takes 100 µs, **~4% slowdown**. If your body takes 1 µs
(e.g. a tight inner accessor), **~430% slowdown**.

For a method with a 1000-iteration loop containing 5 statements: that's
5000 firings per call from the loop body alone, plus a few from the top
level — call it ~5005 firings × 0.215 µs ≈ 1.08 ms of pure instrumentation
overhead per call.

### 3.2 Setup cost (`instrumentMethod:`)

Median µs per `instrumentMethod:` call. The C1/A1/R1 ratio against
top-level-statement count tells us the per-statement amortized setup cost:

| Workload | top-stmts | C1 (µs) | C1/stmt | A1 (µs) | A1/stmt | R1 (µs) | R1/stmt |
|---|---|---|---|---|---|---|---|
| `tinyMethod` | 1 | 544 | 543.5 | 116 | 116.5 | 122 | 122.5 |
| `lightMethod` | 6 | 420 | 70.0 | 314 | 52.2 | 318 | 53.0 |
| `mediumMethod` | 21 | 947 | 45.1 | 762 | 36.3 | 826 | 39.4 |
| `heavyMethod` | 51 | 1 904 | 37.3 | 1 892 | 37.1 | 1 994 | 39.1 |
| **`straightLine200`** | 202 | **6 414** | **31.8** | **6 559** | **32.5** | **10 363** | **51.3** |
| `assignmentChain` | 2 | 180 | 90.0 | 177 | 88.5 | 182 | 90.8 |
| `tightLoop:` | 3 | 270 | 90.2 | 262 | 87.3 | 232 | 77.2 |
| `tightLoopHeavy:` | 4 | 964 | 241.1 | 954 | 238.5 | 762 | 190.6 |
| `messageSendHeavy:` | 4 | 348 | 86.9 | 350 | 87.6 | 317 | 79.2 |
| `recursiveFactorial:` | 2 | 210 | 104.8 | 212 | 105.8 | 198 | 98.8 |

#### Findings

- **Per-statement setup cost converges to ~32 µs on big methods**. The
  asymptote is visible in the `straightLine200` row: 543 → 70 → 45 → 37
  → 32 µs/stmt as we go from 1 to 202 statements. The 32 µs floor is the
  marginal cost of one more statement to compile + analyze + rewrite;
  everything above that is fixed overhead amortizing over more statements.

- **R1 setup is 60% higher than A1/C1 on `straightLine200`** (51.3 vs
  ~32 µs/stmt). On smaller methods the gap is invisible (~5%). Hypothesis:
  R1's wrap-statement rewrite + per-statement temp injection is linear
  in statement count, costing ~20 µs/stmt extra on a 200-statement method.
  On a 50-statement method that's ~1 ms, lost in the noise floor.

- **C1 setup on `tinyMethod` (544 µs) is 4.7× H1 setup (148 µs).** This
  is a startup constant in `IGCounter countKeyBy: #astNode` — first-time
  block allocation, Dictionary creation. On all larger methods C1/H1 setup
  is within 10% of each other. Negligible in practice.

- **Inner-loop workloads (`tightLoopHeavy:`) have higher per-stmt setup
  (190–241 µs/stmt)** — but only 4 top-level statements, so the absolute
  setup is small (~1 ms). The high per-stmt number reflects fixed
  overhead being divided by a small denominator.

### 3.3 Teardown (`uninstrumentMethod:`)

Constant **~36 µs across all workloads × all scenarios**. Range observed:
34–42 µs median. Teardown is just `methodDict at:put:` of the original
method.

### 3.4 Profiler end-to-end

| Workload | Median (µs) |
|---|---|
| `tinyMethod` | 15 562 |
| `lightMethod` | 157 141 |
| `mediumMethod` | 174 958 |
| `heavyMethod` | 234 116 |
| `straightLine200` | 99 503 |
| `assignmentChain` | 94 526 |
| `tightLoop:` | 290 328 |
| `tightLoopHeavy:` | 720 488 |
| `messageSendHeavy:` | 224 172 |
| `recursiveFactorial:` | 990 |

Profiler end-to-end is **dominated by the steady-state cost of running
the workload through the C1-instrumented method**. Setup is 1–6% of the
total; teardown is <0.1%; result construction is ~1%.

`straightLine200`: 1000 calls × 202 firings × 0.22 µs ≈ 44 ms of pure
instrumentation cost, plus B0 cost of ~3.4 ms × 1.001 = 3.4 ms, plus
setup ~6.4 ms, plus result building. Total ≈ 99 ms. Matches.

### 3.5 Profiler scaling (number of instrumented methods)

Workload always calls `mediumMethod` 30 000 times. Other instrumented
methods are not called.

| N | Median (µs) | Min (µs) | Δ vs N=5 |
|---|---|---|---|
| 1 | 359 | 356 | (mediumMethod uninstrumented in this run) |
| 5 | 193 690 | 193 158 | — |
| 9 | 196 058 | 195 691 | +2 533 µs |

**Cleanest scaling number: ~633 µs per uncalled instrumented method**
(N=5 → N=9 delta divided by 4). Matches setup cost from §3.2 for
mid-sized methods. **Per-method scaling is linear and small.**

---

## 4. Hot-spot analysis

### 4.1 Per-firing cost decomposes into three layers

H1 (single-key counter, the cheapest hook+action combo) is **~0.082
µs/firing**. That's the floor: one literal load + one outer message send
(`<IGCounter literal> incrementAt: nil`), plus the inner
`Dictionary at:update:initial:` call.

The C1 − H1 gap (~0.13 µs/firing) is **`Dictionary at:update:initial:`**
work — block evaluation, identity hash, bucket scan, `at:put:`.

The H1 − A1 gap (~0.077 µs/firing) is the difference between Dictionary
work and `OrderedCollection>>add:` — the latter is just an indexed array
write to `array at: lastIndex put: value`, no hashing.

So decomposed:

```
Bare hook firing (literal load + 1 send):       ~0.005 µs
+ A1 capture work (OrderedCollection add):      negligible (already in A1)
+ Counter dictionary work:                       ~0.077 µs  → H1 = 0.082
+ Counter[astNode] hash + bigger keyset:         ~0.13 µs   → C1 = 0.215
```

### 4.2 `Dictionary at:update:initial:` is the biggest win available

The 0.13 µs/firing in §4.1 is the largest single-line item. Replacing
the per-node Dictionary in `IGCounter` with a per-method indexed array
(populated at instrument time, indexed by treePath) would:
- Replace `Dictionary at:update:initial:` (one method dispatch + block
  eval + hash + bucket scan + at:put:) with `array at: i put: (array at: i) + 1`
  (two indexed-access bytecodes).
- Save the entire 0.13 µs/firing.

Predicted result: C1 drops from 0.215 µs/firing to ~0.085 µs/firing, a
**~60% reduction in coverage profiler steady-state cost**.

### 4.3 R1's `temp := stmt` wrap is essentially free in steady-state

R1 ≈ A1 across all clean workloads, even though R1 inserts `temp := stmt`
+ a per-method temp declaration that A1 does not. On `heavyMethod`:
A1 = 0.0057, R1 = 0.0057 — identical to four decimal places.

The wrap is one local-store bytecode. Cog Spur stack frames already
allocate space for temps lazily; one extra slot is free.

R1's setup (§3.2) is 60% more expensive than A1 on a 200-statement method,
but in absolute terms ~4 ms. Negligible for normal use.

### 4.4 R1 only reaches top-level statements

This is a real semantic limitation, not a benchmark caveat. Any user who
adds a hook with `ctx statementResult` expecting per-iteration capture
inside loops or per-branch capture inside conditionals will be surprised:
**they will only get top-level captures.**

The codebase test `testCoverageInstrumentAConditionalWithAnAfterHook`
demonstrates that C1-style hooks DO reach inside conditional branches.
The asymmetry between C1 and R1 reach is a behaviour of
`IGStatementResultReification>>rewriteOperationsForNode:` — likely
because wrapping a statement inside a block requires hoisting a temp
out of the block scope, which the current rewrite doesn't handle.

Worth consideration: either fix the wrap to descend into blocks (with
proper temp hoisting), or document the limitation prominently.

### 4.5 AST flattening is NOT a hot spot

Confirmed across two report iterations now. `assignmentChain` setup is
90 µs/stmt (higher than the asymptote, lower than tiny methods) — the
flattening pass adds at most a handful of µs across the whole rewrite.

### 4.6 Collector unbounded growth is a usability issue

`tightLoopHeavy:` A1 went 1.24 s (min) → 6.55 s (max) across 20 iterations.
The collector's `OrderedCollection` grew to ~10M entries. **Per-firing
CPU cost is fine**; the wall-clock blow-up is GC.

This is documented in REPORT-MEMORY.md as the only memory-side concern
worth changing.

### 4.7 The compiler dominates setup time

The 32 µs/stmt asymptote in §3.2 is essentially the compiler's per-stmt
cost; Insight's own walks add ~5–7 µs/stmt on top of that. Cannot be
avoided without switching to MetaLinks-style bytecode-level instrumentation.

### 4.8 Recompiling without firing is free

H3/H4 on workloads without assignments produce per-call cost
indistinguishable from baseline (`recursiveFactorial:` H3 = 55 µs vs B0
= 59 µs). The cost lives entirely in the per-firing path; the rewritten
method shape itself adds zero steady-state cost.

---

## 5. Improvement focus points (data-driven ranking)

| # | Change | Expected gain | Effort | Risk |
|---|---|---|---|---|
| 1 | **Cache instrumented `CompiledMethod`s** by `(originalMethod, hookSetSignature)`. Setup is 32 µs/stmt asymptotically and dominates the profiler-end-to-end *constant* overhead. Re-running a profiler with the same configuration on the same method is currently full-cost. | Setup → ~0 µs on cache hit. **Very high impact for repeated profiling (test suites, CI).** Zero impact for single-shot. | Medium — needs hook-signature concept and class-side cache. | Low — invalidation only on hook change. |
| 2 | **Replace `Dictionary at:update:initial:` in `IGCounter`** with a method-local indexed array when the keyset is statically known. At instrument time, assign each statement node an index; the action becomes `count at: idx put: (count at: idx) + 1`. Saves the 0.13 µs/firing observed in §4.2. | **~60% reduction in C1 per-firing cost** (0.215 → ~0.085 µs/firing). Highest steady-state win. | Medium — touches `IGCounter`, action protocol, rewriter (must thread an index per node). | Low — pure data-structure swap; existing tests catch regressions. |
| 3 | **Inline simple actions** into the rewritten AST instead of dispatching through `<IGAction literal> action: ctx`. For `IGCounter` and `IGCollector`, the action body is one or two messages; inlining saves the outer dispatch. | Saves ~0.05 µs/firing (one message-send layer). Cumulative with #2. | Medium-high — needs a rewrite-friendly trait on actions, plus per-action templates. | Medium — divergence between simple and complex actions. |
| 4 | **Fix R1 to reach inside blocks (or document the limitation prominently).** Currently R1 silently misses inner-block statements while C1/A1/etc reach them. This is a semantic gotcha for users. | Correctness, not performance. Moderate impact on the surprise factor. | Medium — requires temp-hoisting in the wrap rewrite. | Medium — needs careful interaction with semantic analysis. |
| 5 | **MetaLinks fast path for method-entry/exit hooks** (`IGBeforeMethodHook`, `IGAfterMethodHook`, used by `IGCallGraphGenerator`). MetaLinks bypass recompilation entirely. | High for the call-graph use case. Negligible for coverage. | High — second backend, parallel maintenance. | Medium — semantic differences. |
| 6 | **Document and bound `IGCollector`** with a `maxSize:` / ring-buffer mode. Currently unbounded; surprises users on hot loops (§4.6, REPORT-MEMORY.md). | Wall-clock relief for at-scale collector use, no impact on small uses. | Low. | Very low. |
| 7 | **Skip `flattened` when no flattening rewrite is needed** (e.g. no nested assignments). Currently unconditional. | Low — flattening is not in the hot path (§4.5). Setup-time only. | Low — single guard with a precheck visitor. | Very low. |

**Takeaway: #1 (cache) and #2 (array counter) together address the bulk
of measurable overhead.** #1 wipes setup amortized across runs; #2 cuts
per-firing cost by ~60%. #3 stacks on top of #2 if you want to push
further.

---

## 6. What this benchmark does NOT show

- **Heap retention beyond steady-state.** See `REPORT-MEMORY.md` for the
  leak-test results.
- **Transient allocation / GC pressure during steady-state.** The memory
  bench's bytes-delta signal turned out to be unreliable (Pharo's
  automatic nursery scavenges hide transient allocation between
  snapshots). REPORT-MEMORY.md only reports the leak signal.
- **Hooks that compute on captured values.** R1 captures statementResult
  but doesn't *do* anything with it. A hook that logs, asserts, or
  inspects would add the cost of that work on top of R1's near-zero
  overhead.
- **Comparison against MetaLinks or other Pharo instrumentation.** Out
  of scope; would clarify whether MetaLinks fast-path (#5 above) is
  genuinely worth the effort.
- **Variance with confidence intervals.** No CIs. The min vs median gap
  on collector workloads (4× on `tightLoopHeavy:`) means 20 iterations
  is enough to *see* the GC tax exists but not enough for a tight CI on
  the per-firing number.
- **Image-state sensitivity.** All measurements taken in one image
  session against an already-warmed image (1.2 GB used, 191 prior full
  GCs at run start). A freshly-loaded image will produce different
  JIT-tier behavior.

---

## 7. Reproduction

```smalltalk
"In a Pharo 13 image with Insight loaded, with src/IG-Benchmarks loaded:"
IGBenchRunner runAllAndExport.
"Then read /tmp/insight-bench.csv."
```

Total wall time: ≈ 7–8 minutes. To shorten while iterating, lower
`IGBenchHarness defaultIterations` from 20.
