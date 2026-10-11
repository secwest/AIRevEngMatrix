# Matching, component identity, and runtime artifacts

This guide covers concrete engines for comparisons, software inventory, capability discovery, system memory, and recorded execution. [Process and reconstruction](process-and-reconstruction.md) defines behavioral comparisons; [Native and artifacts](native-and-artifacts.md) covers executable structure and recorded crashes.

## Engine selection

| Engine | Role | Conditions and limits |
| --- | --- | --- |
| [Diaphora](https://github.com/joxeankoret/diaphora) | Match and compare functions exported from compatible IDA analyses | Record IDA/Diaphora versions, analysis settings, export schemas, and matching heuristics. Similarity is not semantic equivalence. |
| [Syft](https://github.com/anchore/syft) | Inventory recognized software components in filesystems, archives, and supported image formats | Extract unsupported firmware containers first. Stripped or statically linked code may need separate identification. |
| [capa](https://github.com/mandiant/capa) | Find capability candidates from rules over supported executable or analysis inputs | Preserve ruleset version, input mode, feature locations, and warnings. Packed or unsupported code can limit analysis. |
| [FLOSS](https://github.com/mandiant/flare-floss) | Recover supported static, stack, tight, or decoded strings | Preserve extraction category, encoding, source/decoding locations, and emulation limits. A recovered string does not prove a reachable behavior. |
| [Volatility 3](https://github.com/volatilityfoundation/volatility3) | Extract artifacts from supported system memory images | Match OS/build, address layers, symbols, plugins, and image completeness. Acquisition is a separate operation. |
| [rr](https://rr-project.org/) | Record and replay supported Linux process execution for deterministic debugging | Check CPU, kernel, permissions, and supported process features. Replay fidelity applies to the recorded execution and modeled external effects. |

## Function and release matching

Template: [comparison and inventory](../assets/templates/comparison-inventory.yaml), mode `function_match`.

Select comparable components using artifact role, architecture, build identity, and packaging provenance. Preserve analysis database digests or export identities, tool versions, autoanalysis completion, and function-boundary decisions. Export with Diaphora's supported IDA integration and retain the databases/results needed to reproduce matching.

Keep exact matches, heuristic matches, ambiguous candidates, unmatched functions, and analysis failures separate. Match evidence can include bytes, normalized instructions, control flow, calls, constants, and pseudocode; compiler optimization and inlining can alter each. One-to-one matching can fail for split, merged, or inlined functions.

Check decisive changes in both original instruction streams. Recovered names/comments imported into a database retain their source and confidence; they do not change the binary's provenance. A suspected behavioral change needs a targeted scenario when execution conditions matter.

**Deliverable:** match table with source addresses, confidence basis, checked changes, ambiguous/unmatched cases, and any runtime comparison. An empty diff is meaningful only within successfully analyzed and matched scope.

## Components and software inventory

Template: [comparison and inventory](../assets/templates/comparison-inventory.yaml), mode `component_inventory`.

Scan an identified extracted tree or supported image with Syft. Record the scan root, cataloger selection, excluded paths, tool version, extraction provenance, and raw output. Select an output format such as Syft JSON, SPDX, or CycloneDX according to the consumer; retain source paths and identification evidence during conversion.

Check representative identities against package manifests, installed package databases, embedded build metadata, or other independent evidence. Track unrecognized files and static-library candidates separately. Filesystem presence does not establish startup, remote reachability, or use in an observed run. A package/version match alone does not establish vulnerability or patch status; vendor backports and build options can change those conclusions.

**Deliverable:** scoped component inventory/SBOM, evidence paths, confidence and version ambiguities, exclusions, and unresolved components. License or vulnerability analysis can consume the inventory when requested, with its own checks.

## Capability and string discovery

Template: [comparison and inventory](../assets/templates/comparison-inventory.yaml), mode `capability_strings`.

Run capa and/or FLOSS only when the selected input is supported and their output helps answer the question. Preserve binary digest, tool/rule versions, input mode, warnings, and original structured output. Keep capa rule matches and FLOSS string categories distinct.

For each decisive lead, inspect the supporting function/instruction or recovered buffer and its callers. A decoded string needs its decoding origin and, where meaningful, a checked reproduction. The [encoded-string fixture](../assets/fixtures/encoded-string.yaml) provides a known XOR-encoded string (key and plaintext) and a stack-constructed string with their in-blob offsets, while asserting that a recovered string is a candidate, not proof of a reachable path (see [format fixtures](format-fixtures.md)). A match on library code can be present without an application path invoking it. Packed, partially analyzed, or unsupported inputs cannot justify conclusions from absent matches.

**Deliverable:** prioritized leads with exact locations, confirmed findings, rejected hypotheses, and unresolved coverage. Full raw output remains available without presenting every match as an established behavior.

## System memory

Template: [memory and replay](../assets/templates/memory-replay.yaml), mode `memory_image`.

1. Record acquisition method, capture time/window, image digest, format, physical coverage, and known gaps or instability.
2. Establish supported OS/build and address layers. Record symbol sources, identities, caches, and plugin versions. A profile/symbol mismatch can produce plausible but wrong structures.
3. Select plugins for the question: processes, modules, mappings, handles, network state, or another supported artifact. Preserve raw plugin output and errors.
4. Link findings to process identity, virtual address, backing layer/offset where available, and capture time. A PID alone does not identify the same process across captures.
5. Check a decisive structure through an independent view or raw bytes. Page absence, corruption, acquisition races, and unsupported plugins remain explicit.

Extracted memory ranges may have missing pages, relocations, runtime patches, or absent file headers. Keep a memory extraction and a reconstructed executable as separate artifacts. Hash each transformation and validate rebuilt layout before passing it to a file analyzer.

**Deliverable:** question-specific runtime artifacts with source coordinates, symbol provenance, acquisition limitations, and verified extraction/reconstruction status.

## Recorded execution and reverse debugging

Template: [memory and replay](../assets/templates/memory-replay.yaml), mode `record_replay`.

Check rr compatibility on the actual Linux host before choosing it. Record exact executable/libraries, environment, arguments, inputs, process tree, and trace storage. The initial recording executes the program and can have external effects. Bound the run and preserve the trace with its dependencies using the installed version's supported packaging method.

Replay a known event first and verify module identities, breakpoint locations, and the expected output. Then use forward or reverse debugging to locate the write, branch, or syscall relevant to the question. Record the event/thread/location and the state that supports the conclusion. Changes introduced during debugger exploration are distinct from the original recording.

**Deliverable:** the replayable trace when transferable, reproduction conditions, causal event explanation, and unsupported or unrecorded external behavior. A single recorded schedule does not establish all possible concurrent executions.
