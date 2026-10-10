# AIRevEngMatrix

AIRevEngMatrix is a reverse engineering skill and reference library for investigating software and firmware. It helps turn a concrete question into a small analysis toolkit, then a finding that can be checked against the original bytes or an observed run.

A question might be: what does this function do, which program starts this device's network service, what changed between two releases, or which responses identify a particular implementation? The toolkit depends on the question. Reading an executable's imports may need one parser. Explaining a device's update process may need an image extractor, a disassembler, and a capture from the device.

The repository supplies selection guidance, analysis procedures, adapter specifications, and result checks. Analysis engines are separate dependencies. There is no bundled server, mandatory tool stack, or prebuilt collection of executable adapters.

## How an investigation works

1. **Define the result.** Identify the question, target, and evidence needed to answer it.
2. **Choose the tools.** Check which installed tools understand the format, processor, runtime, or device involved.
3. **Collect the relevant facts.** Read structure and code, extract components, or observe a bounded run. A small script or adapter connects tools when their outputs need joining.
4. **Check the finding.** Verify important offsets, identities, call sites, or observations against the source. Record unresolved steps.
5. **Deliver the result.** Return the explanation, extracted files, comparison, or verification report with enough detail to reproduce the decisive checks.

```mermaid
flowchart TD
    Q[Question and target] --> S[Select the smallest useful toolkit]
    S --> F[File and firmware structure]
    S --> C[Code and data analysis]
    S --> R[Runtime or device observation when needed]
    F --> J[Combine relevant facts with a small adapter if needed]
    C --> J
    R --> J
    J --> V[Check identities, locations, and observations]
    V --> D[Finding and supporting artifacts]
```

These branches are choices. A file-format question can finish without a debugger or device. Graphs and evidence bundles become useful when a finding spans several components or needs to be transferred and audited.

## What can be analyzed

| Target family | Typical questions | Results |
| --- | --- | --- |
| Native executables and libraries | What does a function do? How does an input reach an API? Which imports, resources, or protections are present? | Binary layout, disassembly, decompiler interpretation, call references, type and dispatch candidates |
| Apple applications | Which executable and resources make up the app? How is a UI action connected to code? What does the signature cover? | Bundle inventory, resources, entitlements, Objective-C/Swift metadata, supported UI-to-code links |
| .NET and Android applications | Which methods implement a feature? Where are native boundaries? Is acquisition of an installed app complete? | Assembly or DEX structure, decoded resources, method traces, APK/split inventory, device observations |
| JavaScript, Electron, and websites | Which module handles an action? What crosses an IPC boundary? Which source is recoverable? | Module and handler relationships, source locations, captured scripts, browser scenarios and traffic |
| Embedded Linux, MCU/RTOS, and UEFI firmware | What is in the image? How does it boot? Which service is exposed? How are updates checked? | Region and partition maps, extracted files, boot paths, task/interrupt analysis, update and trust-path findings |
| Processes, protocols, and crashes | What happened during a run? How are messages framed? Which signals are remotely visible? | Process effects, crash state, message sequences, fingerprint candidates with tested conditions |
| EVM bytecode | Which dispatch branches, selectors, events, and storage accesses are visible? | Instruction-anchored interface candidates and unresolved ABI details |
| Releases and reconstructions | What changed? Does a replacement reproduce the required behavior? | Matched and unmatched changes; passing, failing, missing, and incomparable cases |

The [capability matrix](references/capability-index.md) maps individual questions to methods, outputs, and checks.

## Tool taxonomy

Tools have different roles. A **parser** reads a file's structure; a **disassembler** decodes instructions; a **decompiler** proposes higher-level code; a **debugger or tracer** records execution; an **emulator** runs code against a modeled environment. An **adapter** is the small amount of glue needed to select inputs, invoke an engine, preserve locations, and return a usable result.

The tools below are candidates described by the methods. Inclusion does not mean they are bundled, installed, interchangeable, or supported for every target. Libraries and CLIs can be used directly; a new adapter is useful only when the requested result needs one.

### Files, code, and application packages

| Tool class | Candidate tools or interfaces | Role and main limits | Method |
| --- | --- | --- | --- |
| Identification and extraction | Header readers, hash libraries, ZIP/TAR/CPIO readers, format-specific extractors | Identify bytes and recover members; preserve original names and extraction provenance | [Artifacts](references/native-and-artifacts.md) |
| Executable structure | LIEF, pyelftools, pefile, macholib, LLVM tools | Read ELF, PE, or Mach-O structure as supported; file offsets and memory addresses have different meanings | [Native layout](references/native-and-artifacts.md) |
| Native disassembly and decompilation | Ghidra, IDA, Hopper, Rizin, JEB | Recover instructions, references, functions, and higher-level interpretations; processor support and decompiler availability depend on the engine and edition | [Native code](references/native-and-artifacts.md), [JEB](references/managed-mobile-firmware.md) |
| Apple resources and metadata | `plutil`, `ibtool`, `assetutil`, `codesign`, `otool` | Inspect bundles, resources, signing, and loader metadata; availability and output vary with the Apple toolchain | [Apple applications](references/native-and-artifacts.md) |
| .NET metadata and CIL | dnfile, dnlib, System.Reflection.Metadata, ILSpy, `ildasm` | Read assemblies and intermediate language; Native AOT code follows the native-analysis path | [Managed code](references/managed-mobile-firmware.md) |
| Android packages and resources | `aapt2`, `apkanalyzer`, Apktool, JADX, JEB | Decode package metadata, resources, DEX, smali, or decompiled code; split packages and native libraries need explicit coverage | [Android packages](references/managed-mobile-firmware.md) |
| JavaScript syntax and modules | Babel, Acorn, SWC, TypeScript AST APIs | Parse syntax and trace imports, handlers, and calls; dynamic loading and computed names may remain unresolved | [JavaScript](references/javascript-and-web.md) |
| Electron packaging and source recovery | `@electron/asar`, source-map libraries, formatters, Wakaru | Read shipped modules and recover readable representations; missing external members or original sources remain gaps | [Electron and sources](references/javascript-and-web.md) |
| EVM decoding | Strict hex/bytecode decoder, EVM disassembler or analysis engine | Identify dispatch, event, and storage patterns; an inferred selector label does not establish a full ABI | [EVM](references/native-and-artifacts.md) |

### Firmware and hardware

| Tool class | Candidate tools or interfaces | Role and main limits | Method |
| --- | --- | --- | --- |
| Region discovery | Binwalk, Unblob, bounded signature and entropy scans | Locate candidate embedded formats; important hits need parser validation | [Image identification](references/firmware.md) |
| Filesystem and container recovery | Unblob, SquashFS, UBI/UBIFS, JFFS2, ext and CPIO tools | Recover components and files with metadata; flash geometry, compression, and logical extents affect mapping | [Extraction](references/firmware.md) |
| Boot and update metadata | U-Boot/FIT tools, `dtc`/libfdt, partition parsers, Android OTA and logical-partition parsers | Read image selection, hardware description, load addresses, update operations, and slot relationships; delta updates may require an exact base image | [Boot and updates](references/firmware.md) |
| UEFI and PC firmware | UEFITool/UEFIExtract, firmware-volume and PE/COFF parsers, CHIPSEC | Inspect volumes, modules, variables, and platform state; static parsing and privileged hardware operations have different requirements | [UEFI](references/firmware.md) |
| Emulation and device observation | QEMU, serial capture, OpenOCD with a compatible probe, GDB | Observe a process, supported machine, or physical target; CPU support alone does not supply a board's peripherals | [Runtime observation](references/firmware.md) |

### Runtime, traffic, and comparison

| Tool class | Candidate tools or interfaces | Role and main limits | Method |
| --- | --- | --- | --- |
| Native debugging, tracing, and crashes | GDB, LLDB, WinDbg, Frida, platform tracing and accessibility APIs | Inspect state, calls, crash dumps, or UI observations; correct modules and symbols are essential | [Native runtime](references/native-and-artifacts.md) |
| Android device access | ADB | Inventory a selected device and acquire apps, files, logs, or screenshots; device state and permissions determine access | [Device operations](references/managed-mobile-firmware.md) |
| Browser and Node/Electron observation | Chrome DevTools Protocol, V8 Inspector, Electron DevTools | Capture loaded scripts and events within an attach window; target and domain coverage constrain conclusions | [Runtime capture](references/javascript-and-web.md) |
| Browser scenarios | Playwright or an equivalent action harness | Replay interactions and assert outcomes with controlled browser settings | [Scenarios](references/javascript-and-web.md) |
| Advertised browser tools | Experimental WebMCP interface, when exposed by the selected browser | Discover advertised names and schemas; browser/version support and invocation permissions are separate | [Discovery](references/javascript-and-web.md) |
| Traffic and protocol analysis | Wireshark/TShark, PCAP/PCAPNG parsers, HAR/CDP logs, mitmproxy captures | Reassemble and compare messages; missing packets, encryption, proxies, and capture gaps limit attribution | [Protocols](references/process-and-reconstruction.md), [web traffic](references/javascript-and-web.md) |
| Process scenarios | Host process APIs, PTY/ConPTY, Windows Job Objects where needed | Record input, output, exit state, and selected effects; a capture harness does not itself isolate a program | [Processes](references/process-and-reconstruction.md) |
| Differences and reconstruction | Digest/member manifests, instruction/AST/CIL comparators, image diffs, scenario comparators | Align matching inputs and compare structure or behavior; similarity and passing examples have a bounded scope | [Comparison](references/process-and-reconstruction.md) |
| Evidence and navigation | Small JSON adapters, bounded graph queries, digest-checked bundles, optional obligation ledgers | Preserve supporting records and unresolved questions for larger investigations | [Evidence](references/evidence-and-runtime.md) |

An installed engine still needs the right version, architecture support, license where applicable, and accessible API or CLI. Hardware observation also needs the actual device and compatible interfaces. The [assembly guide](references/assembly-patterns.md) describes these selection decisions.

## Example toolkits

| Question | Small starting toolkit | Deliverable |
| --- | --- | --- |
| Which libraries does this PE import? | Hash plus PE parser | Import list with source offsets and parsing limitations |
| Which program starts the web service in this firmware? | Image extractor plus init/config inspection; disassembler if startup remains unclear | Startup chain, executable/config paths, and supported listener candidates |
| What does this MCU interrupt handler do? | Memory map plus one compatible disassembler | Handler explanation with vector entry, memory accesses, and uncertain hardware behavior |
| Where does this Electron button write a file? | ASAR/member reader, JS parser, selected runtime capture when needed | UI-to-IPC-to-filesystem path with evidence at each boundary |
| Can this service be identified remotely? | Existing captures or bounded authorized probes, protocol decoder, comparison controls | Observable signals, preconditions, stability, and attribution limits |
| Does a replacement preserve the required behavior? | Original fixtures, process or browser harness, focused comparator | Results for each required case and explicit gaps |

## Use and repository guide

The repository root is a skill directory. It can be installed under the name `reverse-engineer-direct` in a compatible host's skills directory, or used as a reference library. An investigation needs a concrete question and the relevant artifact, capture, or accessible target. Tool installation and device access depend on the execution environment.

| File | Purpose |
| --- | --- |
| [SKILL.md](SKILL.md) | Skill entrypoint and routing |
| [Capability matrix](references/capability-index.md) | Analysis questions, expected results, and checks |
| [Toolkit assembly](references/assembly-patterns.md) | Tool selection and adapter design |
| [Native artifacts](references/native-and-artifacts.md) | Native code, Apple bundles, crashes, and EVM |
| [JavaScript and web](references/javascript-and-web.md) | Shipped source, Electron, browser capture, and scenarios |
| [Managed code and mobile devices](references/managed-mobile-firmware.md) | .NET, Android packages, ADB, and JEB |
| [Firmware](references/firmware.md) | Image recovery, embedded Linux, MCU/RTOS, UEFI, boot, and updates |
| [Process, protocol, and comparison](references/process-and-reconstruction.md) | Observed behavior, fingerprints, differences, and reconstruction |
| [Graph and evidence conventions](references/evidence-and-runtime.md) | Optional structures for joins, provenance, and audit |

## What a result establishes

A useful finding includes the answer, target identity, decisive offsets or observations, key tool versions, and material gaps. New parsers and adapters need a known fixture and a relevant target check; malformed-input checks matter when decoding untrusted structures. The capability matrix specifies checks for each result family.

Decompiled code is an interpretation of compiled bytes. A static call path supports code relationships; runtime evidence establishes what happened in a particular run. A firmware component's presence does not establish that it boots or is reachable. A passing reconstruction test establishes agreement only for the tested cases and observations. These distinctions keep the final answer tied to the evidence available.
