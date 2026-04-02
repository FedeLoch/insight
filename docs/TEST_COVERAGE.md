# Test Coverage Overview

## Existing Tests

### IGASTTest — AST Extension Tests

Tests the `igAssignmentNodes` extension on `OCAssignmentNode` / `OCNode`.

- **`testAssignmentNodeToList`** — Nested assignment (`a := b := 8`) returns both nodes in order.
- **`testAssignmentNodeToList1`** — Single assignment returns only itself.

### IGTest — Core Instrumentation Tests

Tests counters, collectors, hooks.

- **`testCounterWithAnAfterStatementHook`** — Aggregate count of statements executed in a method.
- **`testCounterPerStatement`** — Per-AST-node count; each statement counted individually.
- **`testCountAllStatementExecutionsInAClass`** — Statement count across all methods in a class.
- **`testCountAllAssignmentsInAClass`** — Assignment count across all methods in a class.
- **`testCountAllAssignmentsCallingOnlyOneAssignmentInAClass`** — Partial class exercise; only some assignments triggered.
- **`testCollectArbitraryValueWithAnAfterStatementHook`** — Collect receiver (`self`) after each statement.
- **`testCollectArbitraryValueWithAnBeforeAndAfterStatementHook`** — Collect a temp variable value before and after each statement.
- **`testCollectStatementResultsWithAnAfterStatementHook`** — Collect statement return values.
- **`testCoverageInstrumentAStatementWithAnAfterHook`** — All statements in a sequential method are captured.
- **`testCoverageInstrumentAConditionalWithAnAfterHook`** — True/false branch coverage of an `ifTrue:ifFalse:`.
- **`testInstrumentBeforeReturn`** — Before-hook fires on a `^return` statement.
- **`testInstrumentAfterReturn`** — After-hook fires on a `^return` statement.

---

## Missing / Under-Covered Cases

### 1. Nested / cascaded assignments

`IGAfterAssignmentHook` has its own `acceptsNode:` logic, but there is no test that instruments a method with a nested assignment (e.g., `a := b := expr`) through that hook and verifies both assignments are counted/collected.

### 2. Recursive and re-entrant methods

No test instruments a recursive method and verifies that hooks fire on every recursive call rather than only the outermost one.

### 3. Two hooks of the same type on the same method

There is no test adding two hooks of the same type (e.g., two `IGAfterStatementHook` instances) to the same method and verifying both fire independently without interfering with each other.

### 4. `uninstrumentMethod:` rollback

No test verifies that after instrumentation ends, the original method is restored and subsequent calls no longer trigger hooks.

### 5. Empty methods

There is no test for an entirely empty method (no statements, no explicit return) to confirm hook count is 0 and instrumentation does not crash.

### 6. AST path navigation

`OCProgramNode` extensions (`childAtPath:`, `treePath`, `treePathUpTo:`) are entirely untested.

### 7. Exception propagation during instrumentation

No test verifies that the hook infrastructure itself does not swallow or double-wrap exceptions.

### 8. Statement result reification with side-effecting expressions

`testCollectStatementResultsWithAnAfterStatementHook` uses simple arithmetic. No test covers reification when the statement has a side effect (e.g., a message send that modifies state), ensuring the result is captured exactly once and the side effect is not duplicated.

### 9. Isolated `IGBeforeStatementHook` with variable inspection

`testCollectArbitraryValueWithAnBeforeAndAfterStatementHook` uses both hooks together. There is no standalone test of `IGBeforeStatementHook` collecting a variable whose value changes mid-method, isolating before-hook behaviour from after-hook behaviour.
