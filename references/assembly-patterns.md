# Assemble a minimal toolkit

The capability index names outcomes. The family recipes specify how to obtain them. This page tells the model how to turn a selected subset into code that can be reviewed and rerun.

## Selection algorithm

For a multi-component task, write a short implementation matrix before coding:

| Requested result | Needed fact | Input | Component | Engine/API | Check | Remaining gap |
| --- | --- | --- | --- | --- | --- | --- | --- |

Choose components as a dependency closure from the requested result, not from a fixed tool catalog. Typical dependency order:

```text
input identity + bounded I/O
       -> selected parser or live connector
       -> result-specific trace/comparison
       -> checked answer or output artifact
```

Examples: a PE import question needs an identity check, PE parser and a small report. A browser feature trace may need browser capture, script export and AST relationships. A reconstruction audit needs the relevant analyzers, fixtures and comparison. Use a graph or obligation ledger internally only if it makes the requested result more reliable or reviewable.

## Project shape

Use the host language with the best mature API for the selected target. A small Python or TypeScript project can use:

```text
toolkit/
  analyze.py             # selected analysis entry point, or equivalent
  adapters/              # only when multiple engines need adapters
  fixtures/              # known inputs and expected results
  output/                # requested result and enough raw data to verify it
```

Do not create empty layers just to match this shape. A one-file script is better for a one-question investigation. Add a manifest, shared model, or run archive when repeated analyses or portable results require them.

The common interface can be represented as:

```text
probe(host) -> {available, version, supported_formats, limitations}
analyze(target, request, limits) -> {result, source_locations, limitations, errors}
close() -> cleanup result
```

For live connectors add `attach(target_selector)` and `detach()`; for stateful native engines add `open(snapshot)`. The caller owns target selection and authorization. An adapter never silently switches to another engine after a failure because that can change the evidentiary basis of the answer.

## Engine selection

Prefer a documented installed API to scraping human-oriented text. A CLI with structured JSON output is next. Human text parsing is acceptable when version pinned and verified against fixtures. Implement a direct format parser only for a bounded subset whose rules you can validate; use a mature parser for complex binary formats. Install a large engine only if the requested result needs it and the host allows it. If a requested proprietary engine is missing, mark that capability unavailable rather than silently substituting an engine with different semantics.

When a dependency must be installed, choose an official or trusted package source, pin the version, record license and digest when possible, and follow user/host permission rules. A model may write its own adapter code; it should not claim to have implemented a full decompiler, JEB, browser, emulator, debugger or native sandbox from a short prompt.

## Build sequence

1. **Intake:** validate paths/URLs, identify format, hash original bytes, snapshot mutable inputs. Test malformed and oversize input.
2. **Primitive:** call one parser or engine; retain the output needed to check the claim. Normalize only fields needed by the requested result.
3. **Composition:** add a trace, diff or verifier only when the result requires it. Check coordinate and identity matches before joining facts.
4. **Run:** execute on the selected target, inspect at least one raw result, and compare with an independent signal where feasible.
5. **Deliver:** show the answer, recovered artifact, comparison or verification finding first. Include concise provenance and limitations. Use [graph and evidence documentation](evidence-and-runtime.md) if the result must be audited, transported or extended across several components.

Stopping condition: the requested claim is supported at the required authority, or the remaining gap is named precisely. Do not build extra providers to improve the catalog count.

## Worked assembly patterns

**Native call path.** Hash executable -> parse architecture and image map -> open exact digest in one decompiler -> export functions/calls/xrefs -> breadth-first search from selected entry to target API -> inspect decisive call instructions -> report direct path, unresolved indirect branches and decompiler version. If runtime dispatch matters, add debugger/Frida observation and match module build ID plus load slide.

**Electron UI action.** Hash ASAR and native add-ons -> extract entries -> parse renderer/preload/main import graph -> identify UI event and IPC channel candidates -> attach to selected Electron window or run a controlled scenario -> observe event and IPC/main behavior where available -> join exact script/module identities -> report each edge's authority and gaps.

**APK on device.** Probe adb and select serial -> record device/build/package identity -> pull base and splits, hash -> parse manifest/resources/DEX with installed engines -> trace selected component/class/method -> use bounded logcat or a scenario only if runtime proof is required -> report acquisition completeness and code/runtime joins.

**Reconstruction parity.** Capture authoritative scenario with exact inputs/settings -> derive obligations and required cases -> bind each to reconstruction owner -> run same fixtures against reconstruction -> normalize declared nondeterminism -> compare outputs/effects -> keep failures, unmatched cases and weak authority open.
