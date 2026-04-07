# Insight

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

## Implementation Details

Insight rewrites the methods AST using the Opal Compiler to inject instrumentation nodes:


Key classes:
- `IGInstrumentation` - Core instrumentation responsability
- `IGStatementHook` / `IGAssignmentHook` - Hook types
- `IGInstrumentationContext` - Runtime context provider
- `IGCounter` / `IGCollector` - Built-in actions