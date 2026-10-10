---
name: reverse-engineer-direct
description: Assemble and use a minimal reverse-engineering toolkit for a specific result. Use for binaries, packaged apps, websites, runtimes, devices, firmware images and updates, captures, protocol behavior, and reconstruction verification. Do not invoke for ordinary source-repository review.
---

# Build a task-specific reverse-engineering toolkit

Start with the result the user wants: a function explanation, recovered source, observed behavior, extracted artifact, protocol description, version difference, or verification outcome. Select and build only the analysis components needed to produce that result. The [capability matrix](references/capability-index.md) maps common questions to methods, outputs, checks, and focused implementation recipes. It is a selection guide, not a fixed tool API.

## Workflow

1. State the requested deliverable and the facts that would make it useful. Identify the target, host, authority needed, and relevant matrix rows. Build only that subset.
2. Read [the assembly pattern](references/assembly-patterns.md) and the relevant family recipe below. Inventory installed engines and permissions on the execution host; record their versions. Choose a direct library, CLI, or API when it already gives the needed facts. Implement only the parser, adapter, capture harness, or comparison needed for the deliverable.
3. Define inputs, outputs, limits, failure cases, and a small fixture or known invariant before implementing. Keep untrusted bytes separate from commands and code. Hash every original artifact. Use argument vectors, bounded reads, timeouts, and isolated output directories. A static analyzer must never execute target code as a side effect.
4. Build in the task workspace. Keep enough raw output or reproducible extracts to check the result. Test against a known fixture or target-specific invariant such as an offset round trip, resolved import, member token, observed event order, or comparison match. If an engine is unavailable, produce the narrower result it can support and name the remaining gap.
5. Run the selected toolkit and deliver the result directly, with decisive source locations, commands or adapters, versions, capture window when relevant, and material limitations. Separate observed behavior from static inference. Build a reusable graph, evidence bundle, session registry, or unknown ledger only when the task actually needs one. [Graph and evidence conventions](references/evidence-and-runtime.md) are documentation for those cases, not default components.

## Read the relevant recipe

| When the question concerns | Read |
| --- | --- |
| Native executables, Apple bundles, native UI, crashes, binary layout, EVM bytecode | [Native and artifacts](references/native-and-artifacts.md) |
| JavaScript packages, Electron, web pages, CDP, browser scenarios, source maps, network captures | [JavaScript and web](references/javascript-and-web.md) |
| .NET, Android APKs and devices, JEB | [Managed and mobile](references/managed-mobile-firmware.md) |
| Firmware images, flash dumps, boot chains, embedded Linux, MCU/RTOS or UEFI code, updates, and hardware-assisted analysis | [Firmware](references/firmware.md) |
| Process runs, protocol behavior, comparisons, reconstruction and verification | [Process and reconstruction](references/process-and-reconstruction.md) |

## Design invariants

- Deliver the selected result. Share target identity, errors, or adapter code only where the selected components need them.
- An external decompiler, debugger, browser, device, or licensed product is an engine dependency. The skill can specify an adapter but cannot create that engine, its license, a connected device, or past runtime events. Do not substitute guessed pseudocode for missing engine output.
- Keep static facts, producer claims, and observed execution distinct. A browser attach sees only its capture window. A decompiler's output is a hypothesis to check at important boundaries. An absent event is evidence of absence only when capture coverage is sufficient.
- Make state-changing operations explicit. Browsing a live page can generate requests; browser scenarios, device installs, process execution, annotations, and target writes have distinct effects. Follow the user's authorization and the host's controls.
- Do not load all references for every task. The index supplies coverage and routing; each recipe supplies a build plan for its family. A useful answer or artifact is the primary output; internal bookkeeping supports it.
