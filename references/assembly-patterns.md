# Toolkit assembly

The capability index names outcomes. The family methods describe the analysis components behind those outcomes. A toolkit is the smallest set of components that produces a checkable result for the target.

## Selection algorithm

For a multi-component investigation, the implementation matrix records dependencies and gaps:

| Requested result | Needed fact | Input | Component | Engine/API | Check | Remaining gap |
| --- | --- | --- | --- | --- | --- | --- |

Components form a dependency chain from the requested result. A typical chain is:

```text
input identity + bounded I/O
       -> selected parser or live connector
       -> result-specific trace/comparison
       -> checked answer or output artifact
```

For example, a PE import question needs an identity check, PE parser and a small report. A browser feature trace may need browser capture, script export and AST relationships. A reconstruction audit needs analyzers, fixtures and comparison. Graphs and obligation ledgers are useful when they make the result more reliable or reviewable.

## Project shape

The host language follows the best mature API for the selected target. A small Python or TypeScript project may have this shape:

```text
toolkit/
  analyze.py             # selected analysis entry point, or equivalent
  adapters/              # only when multiple engines need adapters
  fixtures/              # known inputs and expected results
  output/                # requested result and enough raw data to verify it
```

The shape is optional. A one-question investigation may need only one script; repeated analyses or portable results may need a manifest, shared data model, or run archive.

The [template library](templates.md) supplies copyable records for a toolkit plan, firmware acquisition/execution, bus decoding, fuzzing, path queries, format/runtime analysis, matching/inventory, memory/replay, and findings. These records define the experiment and evidence; they are not a universal runner configuration. The included synthetic Kaitai schema is an engine-native parser example with positive and negative fixtures.

The common interface can be represented as:

```text
probe(host) -> {available, version, supported_formats, limitations}
analyze(target, request, limits) -> {result, source_locations, limitations, errors}
close() -> cleanup result
```

Live connectors add `attach(target_selector)` and `detach()`; stateful native engines add `open(snapshot)`. The caller owns target selection and authorization. An adapter that changes engines after a failure changes the evidentiary basis of the answer, so that transition must be explicit.

## Engine selection

An existing documented API or CLI that supplies the needed facts is usually sufficient. Structured output reduces dependence on presentation formatting; its schema and semantics still depend on the tool version. Human-readable output is usable when its format is version pinned and verified against fixtures. Direct format parsers are practical for bounded, validated subsets; complex binary formats usually need mature parsers. A missing proprietary engine leaves its capability unavailable unless another engine's distinct semantics are stated.

Selection depends on target format, processor and instruction mode, ABI, host OS, engine edition, automation interface, and required output. Successful launch does not establish support for the target. Disassembly, decompilation, and debugging can have different architecture coverage in the same product. A format or processor probe and one representative query establish what the selected installation can actually provide.

Dependency records include source, version, license and digest when available; installation remains subject to host permissions. A narrow adapter can connect existing engines, but it is not a substitute for a full decompiler, JEB, browser, emulator, debugger or native sandbox.

## Build sequence

1. **Intake:** path/URL validation, format identification, original-byte hash, and snapshot of mutable inputs; malformed and oversize inputs are test cases.
2. **Primitive:** one parser or engine produces raw output and the fields needed to check the claim.
3. **Composition:** a trace, diff, or verifier joins facts after coordinate and identity matches are checked.
4. **Run:** the selected target yields raw results and, where feasible, an independent comparison signal.
5. **Result:** the answer, recovered artifact, comparison, or verification finding carries concise provenance and limitations. [Graph and evidence conventions](evidence-and-runtime.md) support results that must be audited, transported, or extended across components.

The process ends when the claim has enough support for its intended use, or the remaining gap has been identified precisely. Extra providers add no value without a result they help establish.

## Worked assembly patterns

**Native call path.** Hash executable -> parse architecture and image map -> open exact digest in one analyzer -> export functions/calls/xrefs -> bounded search from selected entry to target API -> inspect decisive call instructions -> report the static relationship, unresolved dispatch, and engine version. Branch conditions and execution state determine path feasibility. If an actual invocation or runtime dispatch matters, debugger/Frida observations can supply it, with module identity and load mapping retained.

**Electron UI action.** Hash ASAR and native add-ons -> extract entries -> parse renderer/preload/main import graph -> identify UI event and IPC channel candidates -> attach to selected Electron window or run a controlled scenario -> observe event and IPC/main behavior where available -> join exact script/module identities -> report each edge's authority and gaps.

**APK on device.** Probe adb and select serial -> record device/build/package identity -> pull base and splits, hash -> parse manifest/resources/DEX with installed engines -> trace selected component/class/method -> use bounded logcat or a scenario only if runtime proof is required -> report acquisition completeness and code/runtime joins.

**Firmware service.** Hash image -> identify and validate container layers -> recover the relevant filesystem and its metadata -> follow init/configuration to the service executable -> inspect listener and handler code -> check a matching capture when remote reachability matters -> report the startup path, externally observable behavior, and missing configuration or hardware dependencies.

**MCU transaction.** Bind firmware and board -> capture a known peripheral transaction -> locate the handler -> create the smallest compatible Renode or other execution model -> record substitutions -> replay input from a defined reset state -> compare the observed output and hardware accesses. [Firmware lab](firmware-lab.md) defines the model and capture checks.

**Parser failure.** Identify the parser boundary and ABI -> establish normal/rejected-input cases -> build a resettable harness -> verify target instrumentation -> run a bounded AFL++ or protocol campaign -> minimize a failure -> replay it with the same environment. [Testing and constraints](testing-and-constraints.md) defines oracles, limits, and concrete witness checks.

**Runtime-specific function.** Identify Wasm/JVM/Python/Go format and version -> choose a supporting engine -> bind function indices, descriptors, code objects, or recovered addresses -> inspect decisive instructions and host/native boundaries -> report the supported interpretation. [Formats and runtimes](formats-and-runtimes.md) defines each identity system.

**Reconstruction parity.** Capture authoritative scenario with exact inputs/settings -> derive obligations and required cases -> bind each to reconstruction owner -> run same fixtures against reconstruction -> normalize declared nondeterminism -> compare outputs/effects -> keep failures, unmatched cases and weak authority open.
