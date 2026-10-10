# Testing, path constraints, and input influence

This guide turns a code or protocol hypothesis into a repeatable experiment. [Process and reconstruction](process-and-reconstruction.md) supplies baseline observation and comparison rules. Firmware execution environments are covered in [Firmware lab](firmware-lab.md).

## Engine selection

| Engine | Role | Required support and limits |
| --- | --- | --- |
| [AFL++](https://aflplus.plus/docs/fuzzing_binary-only_targets/) | Coverage-guided input mutation, including supported binary-only instrumentation | Select source instrumentation or a compatible QEMU/Frida mode. Coverage of the harness alone does not establish coverage of the target function. |
| [boofuzz](https://boofuzz.readthedocs.io/en/stable/) | Structured protocol mutation with connection, session, and monitoring support | Define framing, prerequisite exchanges, reset, and a useful failure oracle. Delivery of test messages is not evidence of code coverage. |
| [angr](https://docs.angr.io/en/latest/) | Symbolic execution, path exploration, and constraint solving | Select loader, architecture, entry state, input model, goals, and finite exploration limits. Unsupported instructions and external calls constrain the result. |
| [Triton](https://github.com/JonathanSalwan/Triton) | Dynamic symbolic execution, taint tracking, and instruction semantics | Supply concrete execution state or a trace driver, memory/register synchronization, and architecture support. The analysis library alone does not acquire a complete process trace. |

## Reproducible fuzzing

Templates: [fuzz campaign](../assets/templates/fuzz-campaign.yaml), [test cases](../assets/templates/test-cases.csv), and [finding](../assets/templates/finding.md).

### Harness contract

The harness identifies one input boundary and an observable outcome. Its specification records:

- Target and dependency digests, architecture, calling convention, entry function or command, and instrumentation mode.
- Input delivery: file, stdin, shared buffer, function arguments, or an ordered protocol exchange. Length, ownership, allocation, and maximum input size are explicit.
- Initial state and reset: globals, heap, thread state, files, connections, device state, and persistent storage. Persistent execution is valid only if each iteration restores the state required by the test.
- Completion, timeout, and failure oracles. A crash, rejected input, disconnect, watchdog reset, assertion, and semantic mismatch are separate outcomes.
- Scope of observation, execution/time/storage limits, and the process/device cleanup method. The harness runs in the selected isolation environment; instrumentation is not itself isolation.

First run a normal input and a known malformed input. Check that the intended target code executes, normal rejection is classified correctly, and repeated runs agree. A deliberately failing test fixture can validate crash collection without assuming a defect in the real target.

### AFL++ campaign

Use the installed version's documented mode and verify that its instrumentation supports the target. Linux binary-only QEMU mode and Frida mode have different loader and architecture constraints. A library needs a calling harness with the correct ABI. Emulating an arbitrary MCU image requires an execution environment beyond selecting `-Q`.

For a Linux file-input target already validated for QEMU mode, the command shape is:

```text
afl-fuzz -Q -i seeds -o campaign -- ./target @@
```

`@@` is an AFL++ input-file substitution. It is appropriate only if the program accepts a file argument there. Command arguments, environment, corpus, instrumentation ranges, timeouts, and target-dependent mode options belong in the campaign record. A finite campaign budget is supplied using the installed tool's controls or a supervisor that stops the owned process tree.

Retain the original seeds and campaign metadata. Check coverage stability before persistent mode or large parallel runs. Corpus reduction preserves a chosen coverage criterion; input minimization preserves the observed failure criterion. Keep both the original and minimized failing input and recheck the failure outside the fuzzing loop with the same target/environment. Deduplicate by a defensible fault/stack/behavior signature and preserve ambiguous cases.

### Protocol campaign

For boofuzz, describe the session graph, transport, framing, lengths/checksums, mutable fields, prerequisite exchanges, monitoring, and restart behavior. Choose whether lengths/checksums follow mutations or are intentionally inconsistent. Keep a known-good exchange to distinguish an unavailable service from a mutation-induced failure.

Record each failure's complete message sequence and connection state. A single packet often cannot reproduce a stateful failure. Recovery includes the relevant server/device state, not just reconnecting a socket. Bound the selected endpoint, rate, case count, and duration according to the experiment. Stop when the reset procedure can no longer establish the baseline.

**Deliverable:** harness and run configuration, corpus, instrumentation/observation scope, failures with classifications, minimized reproducers where valid, and replay results. A campaign without observed failures establishes only its tested scope.

## Symbolic path queries

Template: [path query](../assets/templates/path-query.yaml).

1. Bind the exact binary and coordinate system. PIE load bases, rebasing, Thumb mode, function entry conventions, and runtime relocation affect goal addresses.
2. Define symbolic inputs and all relevant concrete state: registers, stack, heap, global data, files, environment, and dependencies. A blank function state can be cheaper than process initialization, but introduces assumptions about state normally established by callers.
3. Define a positive goal and excluded states. Examples: reach a selected branch with a well-formed message, obtain a specified return value, or show that a field influences a selected write.
4. Set limits for time, steps, active states, loops, memory, and solver queries as appropriate. Record external function summaries and unconstrained state. Avoid treating convenient defaults as actual target behavior.
5. Retain the query, assumptions, visited/errored states, and outcome. Distinguish a satisfying witness, unsatisfiability within the model, exhausted search, timeout, and unsupported execution.
6. Replay a witness on the concrete target or the established emulation harness. Compare the decisive branch/output, not only process exit. A mismatch invalidates the witness as evidence about that target execution and identifies a model gap.

An angr adapter can expose loading, symbolic input creation, bounded exploration, model extraction, and replay as separate steps. Global feasibility does not follow from failure to find a path. Unsatisfiability depends on the constraints and environment model actually checked.

## Dynamic taint and constrained execution

For Triton, identify the taint source by exact bytes/registers and the sink by instruction, argument, memory write, or branch. The driver supplies executed instructions and synchronizes their concrete state. Record unsupported instructions, external calls, instrumentation gaps, and taint policies for memory aliases, implicit control dependence, and sanitizing transformations.

Return an instruction-anchored dependency explanation and the trace scope. Change a selected source byte and replay to test the predicted effect, while preserving the rest of the environment. A tainted path establishes influence under the recorded policy and execution; it does not establish an unsafe outcome or every possible path.

For deobfuscation, retain the original bytes and transformations, then compare the recovered expression or function against concrete cases and stated preconditions. Solver simplification under assumptions can be useful without implying whole-program equivalence.
