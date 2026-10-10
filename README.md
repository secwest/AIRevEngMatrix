# AIRevEngMatrix

A result-first reverse-engineering skill. It helps an agent assemble a small toolkit for a specific investigation from installed analyzers, parsers, debuggers, browser/device APIs, and short task-specific adapters.

The deliverable is the finding: for example, a function explanation, recovered source, extracted firmware region, observed interaction, protocol description, version difference, or reconstruction check. The skill does not require a standing server or a fixed catalog of tool calls.

## Contents

- [SKILL.md](SKILL.md): entrypoint and operating rules.
- [Result capability matrix](references/capability-index.md): questions, minimal methods, outputs and checks.
- [Assembly patterns](references/assembly-patterns.md): how to select and build only the needed components.
- [Native and artifact recipes](references/native-and-artifacts.md).
- [JavaScript and web recipes](references/javascript-and-web.md).
- [Managed, mobile and firmware recipes](references/managed-mobile-firmware.md).
- [Process, protocol and comparison recipes](references/process-and-reconstruction.md).
- [Optional graph and evidence conventions](references/evidence-and-runtime.md).

## Use

Install this directory as a skill named `reverse-engineer-direct` in an agent's skills directory, or give the agent `SKILL.md` and the relevant references. Ask for a concrete result and provide the target artifact, live target or capture. The agent should identify the minimum components, check available engines on its actual host, build the missing adapter if needed, test a fixture or invariant, then return the result with decisive source locations and limitations.

Examples:

- “Explain what this native function does and show the call sites that support the conclusion.”
- “Recover the shipped modules behind this Electron UI action and identify the IPC boundary.”
- “Compare these two APKs and tell me which externally visible behavior changed.”
- “From these authorized captures, describe the protocol state transitions and stable remote fingerprints.”

## Scope

The recipes are specifications, not bundled decompilers or device emulators. Proprietary engines, connected devices, browser sessions and historical runtime events must exist separately. Static interpretation and runtime observation should be reported at their actual level of confidence. Graphs, evidence bundles and ledgers are optional support for investigations that need formal joins, transfer or audit.

## Validation

Validate the skill folder with the Codex skill validator when available. For a toolkit built from a recipe, test a known fixture and at least one target-specific invariant. The matrix lists checks for each result family.
