# AIRevEngMatrix

AIRevEngMatrix describes result-focused reverse engineering with a small, task-specific toolkit. Its components come from installed analyzers, parsers, debuggers, browser/device APIs, and narrow adapters.

The outputs are findings such as a function explanation, recovered source, extracted firmware region, observed interaction, protocol description, version difference, or reconstruction check. The method requires neither a standing server nor a fixed catalog of tool calls.

## Contents

- [SKILL.md](SKILL.md): the skill entrypoint.
- [Result capability matrix](references/capability-index.md): questions, methods, outputs and checks.
- [Toolkit assembly](references/assembly-patterns.md): component selection and interfaces.
- [Native artifacts](references/native-and-artifacts.md).
- [JavaScript and web](references/javascript-and-web.md).
- [Managed code and mobile devices](references/managed-mobile-firmware.md).
- [Firmware](references/firmware.md): image mapping, boot chains, embedded Linux, MCU/RTOS and UEFI code, update logic, and controlled execution.
- [Process, protocol and comparison](references/process-and-reconstruction.md).
- [Graph and evidence conventions](references/evidence-and-runtime.md).

## Use

The directory can be installed as a skill named `reverse-engineer-direct`. An investigation starts with a concrete question and a target artifact, live target, or capture. The work then consists of selecting components, checking available engines, implementing any missing narrow adapter, validating it, and producing a finding with source locations and limitations.

Example investigations:

- A native function dossier with supporting call sites.
- An Electron UI action traced through shipped modules and an IPC boundary.
- An APK release comparison tied to externally visible behavior.
- Protocol state transitions and stable remote fingerprints from authorized captures.
- A firmware update map linked to network-service startup and observable responses.

## Scope

These documents specify analysis methods; they do not bundle decompilers or device emulators. Proprietary engines, connected devices, browser sessions and historical runtime events are separate dependencies. Static interpretation and runtime observation have different evidentiary weight. Graphs, evidence bundles and ledgers support investigations that need formal joins, transfer or audit.

## Result checks

The capability matrix gives a check for each result family. Parser and adapter results also need a known fixture and at least one target-specific invariant, such as a valid offset mapping or a matching extracted-file digest.
