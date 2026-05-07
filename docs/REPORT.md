# Insight Benchmarking Report

> Raw data: produced by AI generated Classes.
> All times in microseconds (µs) unless noted otherwise.

---

## 1. Methodology

### 1.1 Iteration protocol

| Cost type | Warmup | Measured |
|---|---|---|
| Steady-state | 3 | 20 |
| Setup (`instrumentMethod:`) | 0 | 10 |
| Teardown (`uninstrumentMethod:`) | 0 | 10 |
| Profiler end-to-end | 0 | 10 |

### 1.2 Workloads

Inner-loop counts (the unit of one measurement) are listed below.

| Selector | Description | Inner |
|---|---|---|
| `tinyMethod` | `^ 42` | 200 000 calls |
| `lightMethod` | 5 assignments + return | 100 000 calls |
| `mediumMethod` | 20 assignments + return | 30 000 calls |
| `heavyMethod` | `x:=0` + 50 increments + return | 10 000 calls |
| **`straightLine200`** | 200 OrderedCollection sends | 1 000 calls |
| `assignmentChain` | `a := b := c := d := 42` | 100 000 calls |
| `tightLoop:` | `whileTrue:` with 1-stmt body | 500 000 iters |
| `tightLoopHeavy:` | `whileTrue:` with 16-stmt body | 30 000 iters |
| `messageSendHeavy:` | self-send loop | 200 000 sends |
| `recursiveFactorial:` | recursive | depth 500 |

`straightLine200` was added because the original workload set's smaller
straight-line methods could be partially eliminated by the JIT — see §2.1.

### 1.3 Scenarios

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

---

## 2. Critical methodology notes

Two issues affect interpretation. Both are accounted for in §3 calculations.

### 2.1 JIT dead-code elimination on baselines

Several B0 measurements come in absurdly low because Cog's JIT eliminates
their bodies (return value unused, no observable side effect). For
example, `mediumMethod` baseline reads as 0.0074 µs/call, which is below
the cost of a single object allocation. That's the JIT erasing the body,
not real performance.

When a baseline is DCE-affected, use the **absolute per-firing cost**, not
the slowdown ratio. The slowdown ratio reflects the JIT compiler more
than Insight.

### 2.2 Hook reach: most hooks reach inside blocks; R1 does not

A probe revealed that **R1** (Collector capturing `statementResult`)
only fires on top-level statements.

R1's restriction is a property of `IGStatementResultReification>>#rewriteOperationsForNode:`,
which only wraps statements at the top level

### 2.3 Collector growth + GC tax

The collector accumulates into an unbounded `OrderedCollection`. Across
20 measured iterations, on `tightLoopHeavy:` the collector
grows to 10M+ entries:

| Stat | A1 | A2 | R1 |
|---|---|---|---|
| min | 856 825 µs | 2 008 371 µs | 3 689 470 µs |
| median | 2 050 836 µs | 3 354 145 µs | 3 810 986 µs |
| max | 3 686 179 µs | 5 645 076 µs | 3 850 126 µs |

The 4× span between A1 min and max is GC pressure.

---

## 3. Results

### 3.1 Steady-state per-firing cost

**Per-firing cost** = (scenario_min − B0_min) / total_firings_per_measurement.
Total firings depend on hook reach (§2.2).

#### C1 per-firing across all workloads

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

#### Per-firing convergence by scenario

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
   reification at the call site.

2. **H1 ≫ A1/R1 by ~16×** (0.082 vs 0.005 µs/firing). The cost is in
   the `IGCounter` action body itself (Dictionary work) more than in the
   instrumentation send. A collector that just appends a value to an
   `OrderedCollection` is 16× cheaper per firing than a dictionary
   counter.

3. **The `messageSendHeavy:` C1 outlier (0.59 µs/firing)** suggests
   per-firing cost depends on AST-node shape. Coarse expressions =
   bigger reified literals = slower.

#### Per-call overhead

For a method with N statements, the per-call overhead is
roughly `N × 0.215 µs` for C1.

If a method uninstrumented body takes ~10 µs, C1 instrumentation costs **~40% slowdown**.
If the body takes 100 µs, **~4% slowdown**. If the body takes 1 µs
(e.g. a accessor), **~430% slowdown**.

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

- **Per-statement setup cost converges to ~32 µs on big methods**. This floor is the
  marginal cost of one more statement to compile + analyze + rewrite;
  everything above that is fixed overhead amortizing over more statements.

### 3.3 Profiler end-to-end

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

---

## 4. Hot-spot analysis

### 4.1 Per-firing cost decomposes into three layers

```
Bare hook firing (literal load + 1 send):       ~0.005 µs
+ A1 capture work (OrderedCollection add):      negligible
+ Counter dictionary work:                       ~0.077 µs
+ Counter[astNode] hash + bigger keyset:         ~0.13 µs
```

### 4.2 `Dictionary at:update:initial:` is the biggest win available

The 0.13 µs/firing is the largest single-line item. Replacing
the per-node Dictionary in `IGCounter` with something like a per-method indexed array
(populated at instrument time, indexed by treePath) would reduce the cost by an estimate of **60%**.

### 4.3 Collector unbounded growth is a usability issue

`tightLoopHeavy:` A1 went 1.24 s (min) → 6.55 s (max) across 20 iterations.
The collector's `OrderedCollection` grew to ~10M entries. **Per-firing
CPU cost is fine**; the wall-clock blow-up is GC.

### 4.4 The compiler dominates setup time

The 32 µs/stmt asymptote in §3.2 is essentially the compiler's per-stmt
cost; Insight's own walks add ~5–7 µs/stmt on top of that. Cannot be
avoided without switching to MetaLinks-style bytecode-level instrumentation.

---

## 5. What this benchmark doesn't show

- **Hooks that compute on captured values.** R1 captures statementResult
  but doesn't *do* anything with it. A hook that logs, asserts, or
  inspects would add the cost of that work on top of R1's near-zero
  overhead.
- **Comparison against MetaLinks or other Pharo instrumentation.** Out
  of scope; would clarify whether MetaLinks fast-path is
  genuinely worth the effort.
- **Image-state sensitivity.** All measurements taken in one image
  session against an already-warmed image (1.2 GB used, 191 prior full
  GCs at run start). A freshly-loaded image will produce different
  JIT-tier behavior.
- **Memory leaks.** Although this benchmark do not cover the memory aspect
of Insight, there where an attempt to mesure it.
The findings where that Insight have no memory leak but have an issue where
uninstrumentation could not run on failure:
**Adding an exception-safety wrapper around `instrumentMethod:`**
that calls `uninstrumentMethod:` on failure, will ensure the method dict
is restored even if rewriting raises.
