# Insight

[![CI](https://github.com/FedeLoch/insight/actions/workflows/ci.yml/badge.svg)](https://github.com/FedeLoch/insight/actions/workflows/ci.yml)

A dynamic meta-instrumentation framework for Pharo.
Insight enables runtime AST manipulation to inject hooks before/after statements and assignments.

## Installation

```smalltalk
Metacello new
    baseline: 'Insight';
    repository: 'github://FedeLoch/insight:main';
    onConflictUseIncoming;
    load.
```

## Principal Concepts

### Hooks

Hooks define *When* rewritting instrumentation runs:

- **IGBeforeStatementHook**: Applies before each statement
- **IGAfterStatementHook**: Applies after each statement
- **IGBeforeAssignmentHook**: Applies before each assignment
- **IGAfterAssignmentHook**: Applies after each assignment

### Actions

Actions define *What* the instrumentation does:

- **IGCounter**: Counts the number of times a hook is executed
- **IGCollector**: Collects values from the instrumentation context

### Context

The `IGInstrumentationContext` provides access to runtime information:

- `astNode`: Current AST node
- `variableNamed: 'name'`: Read the value of a variable
- `statementResult`: Statement return value
- `break`: Insert a breakpoint

## Some Examples

### Count Statement Executions

```smalltalk
| counter |
counter := IGCounter new.

IGInstrumentation new
    addHook: (IGAfterStatementHook new do: counter);
    instrumentMethod: #example during: [ self example ].

counter count "=> number of statements executed"
```

### Collect Variable Values

```smalltalk
| collector |
collector := IGCollector collect: [ :ctx | ctx variableNamed: 'x' ].

IGInstrumentation new
    addHook: (IGAfterStatementHook new do: collector);
    instrumentMethod: #example during: [ self example ].

collector values "=> all captured values"
```

### Coverage Analysis

```smalltalk
| counter |
counter := IGCounter new countKeyBy: [ :ctx | ctx astNode ].

IGInstrumentation new
    addHook: (IGAfterStatementHook new do: counter);
    instrumentClass: ExampleClass.
```

### Wrap Statements

```smalltalk
| context |
context := IGInstrumentationContext new.

IGInstrumentation new
    addHook: (IGBeforeStatementHook new do: [ :ctx | Transcript show: ctx astNode; cr ]);
    instrumentMethod: #example during: [ self example ]
```

## Code Coverage
The `IG-CodeCov` package provides a high-level coverage profiler built on top of the instrumentation framework.

### Basic Usage

```smalltalk
| profiler result |
profiler := IGCodeCoverageProfiler new.

profiler methodsToinstrument: { MyClass >> #foo . MyClass >> #bar}.
profiler classesToIntrument: { MyOtherClass }.

profiler profileOn: [ MyApplication new run ].
result := profiler coverageResult.
```
### Querying Coverage

Aggregate percentages:

```smalltalk
result fullyCoveredPercentages
result partiallyCoveredPercentages
result uncoveredPercentages
```
Per-method coverage:

```smalltalk
result coverageFor: (MyClass >> #foo). "=> Float in range [0...100]"
```

### Statement Highlighting

Method-list accessors return an object that expose the executed and non-executed statements, in source order:

```smalltalk
result partiallyCoveredMethods do: [ :eachRecord |
    eachRecord method.                  "=> the CompiledMethod"
    eachRecord executedStatements.      "=> AST node than ran"
    eachRecord nonExecutedStatements ]. "=> AST nodes that did not run"
```

## Implementation Details

Insight rewrites the methods AST using the Opal Compiler to inject instrumentation nodes:


Key classes:
- `IGInstrumentation` - Core instrumentation responsability
- `IGStatementHook` / `IGAssignmentHook` - Hook types
- `IGInstrumentationContext` - Runtime context provider
- `IGCounter` / `IGCollector` - Built-in actions
