# Coverage map

Coverage is described across target representation, analysis method, and validation. A named engine is a candidate dependency; documented procedures, a working local installation, a validated fixture, and demonstrated behavior on the actual target are separate states. No finite catalogue guarantees every proprietary format, architecture or compiler release.

Template: [coverage assessment](../assets/templates/coverage-assessment.yaml). [Language decompilation](language-decompilation.md) supplies the source-language view; [operation selectors](operation-catalog.md) describe individual results.

The [development-environment index](development-environments.md) supplies detailed workflows across compiler/runtime families. Its [fixture profiles](environment-fixtures.md) distinguish available source examples, required SDK-specific examples, baseline execution and actual decompiler assessment.

The `fixture checked` state is only claimed where a known-answer fixture actually ships. Today that is the eleven [firmware fixtures](firmware-fixtures.md), the twenty-five [format fixtures](format-fixtures.md) (Mach-O, ELF, PE resources, minidump, eBPF, DEX, JVM class, .NET metadata, `.pyc`, Lua, BEAM, Hermes, IL2CPP, Wasm, source map, Protobuf/CBOR, encoded string, EVM, Go buildinfo, a PCAP TCP capture, an x86-64 decode stream, an evidence bundle, a Unicorn-emulated snippet, an angr-solved path witness, and a crash oracle), the [Rust](../assets/fixtures/rust-patterns.yaml) and [environment](environment-fixtures.md) behavior fixtures, and the [Kaitai](../assets/templates/framed-record.ksy) example. Other routes reach only `documented` or `engine available`; a byte-level fixture is the backlog for closing that gap, not an implied state.

## Target and method routes

| Target or question | Primary route | Reusable record | Target-dependent boundary |
| --- | --- | --- | --- |
| Native code, C/C++, ABI and binary layout | [Native](native-and-artifacts.md), [decompilers](language-decompilation.md) | [Decompilation](../assets/templates/decompilation-study.yaml) | Processor, ABI, decompiler edition, optimization and debug information |
| Rust, including native firmware | [Rust](rust-reverse-engineering.md) | [Decompilation](../assets/templates/decompilation-study.yaml) | Compiler/runtime metadata, supported Rust-specific analysis and type hypotheses |
| Swift/Objective-C and Apple packages | [Native](native-and-artifacts.md) | [Runtime](../assets/templates/runtime-study.yaml) | Metadata, loader context, signing and platform access |
| CIL, .NET and managed/native boundaries | [Managed/mobile](managed-mobile-firmware.md) | [Runtime](../assets/templates/runtime-study.yaml) | CLR versus AOT representation and exact metadata identity |
| JVM, Python, Go and WebAssembly | [Formats/runtimes](formats-and-runtimes.md) | [Runtime](../assets/templates/runtime-study.yaml) | Version-specific bytecode, metadata, host imports and native boundaries |
| Lua variants, Dart, Unity, Hermes, BEAM, legacy and custom VMs | [VMs](virtual-machines.md) | [VM](../assets/templates/virtual-machine-study.yaml) | Compatible decoder, stripped metadata, unknown opcodes and partial reconstruction |
| Julia/JIT specializations and compiled language runtimes | [Languages](language-decompilation.md), [VMs](virtual-machines.md) | [VM](../assets/templates/virtual-machine-study.yaml) | Method/type specialization, compiler conventions, initialization effects and generated code lifetime |
| Android packages and connected devices | [Managed/mobile](managed-mobile-firmware.md) | [Toolkit](../assets/templates/toolkit-plan.yaml) | Complete base/split acquisition, permissions and matching runtime |
| JavaScript, Electron, browsers and web interactions | [JavaScript/web](javascript-and-web.md) | [Toolkit](../assets/templates/toolkit-plan.yaml) | Source maps, capture windows, IPC boundaries and browser support |
| Firmware images, updates, boot and UEFI | [Firmware](firmware.md) | [Format](../assets/templates/format-study.yaml) | Exact base images, transforms, partitions, verifier and active boot selection |
| Unknown-image triage: signatures, architecture, load base | [Firmware triage](firmware-triage.md) | [Firmware triage](../assets/templates/firmware-triage.yaml) | Parser-validated regions, multi-signal architecture, agreeing load-base methods |
| Embedded Linux boot-to-service path | [Embedded Linux services](embedded-linux-services.md) | [Boot chain](../assets/templates/boot-chain.yaml) | Active root/overlay selection, enabled service, confirmed handler and reachability |
| Physical flash and debug acquisition | [Firmware lab](firmware-lab.md) | [Acquisition](../assets/templates/acquisition.yaml) | Electrical/part support, protection, geometry, ECC and address coverage |
| Emulation, MCU/RTOS and peripherals | [Firmware lab](firmware-lab.md), [specializations](firmware-specializations.md) | [Experiment](../assets/templates/firmware-experiment.yaml) | Board models, ABI, interrupts, reset state and unmodeled behavior |
| Registers, secure boundaries, FPGA, PLC and measurement hardware | [Specializations](firmware-specializations.md) | [Hardware](../assets/templates/hardware-scope.yaml) | Device-specific semantics, vendor formats, instruments and acquisition |
| Hardware buses, USB, Bluetooth and RF | [Firmware lab](firmware-lab.md), [specializations](firmware-specializations.md) | [Bus](../assets/templates/bus-decoding.yaml) | Capture layer, clocks, filters, encryption and signal interpretation |
| Hardware instruction and instrumentation traces | [Specializations](firmware-specializations.md) | [Hardware](../assets/templates/hardware-scope.yaml) | Trace source/protocol, transport/sink, exact code image, synchronization and loss |
| Network protocols, structured payloads and remote fingerprints | [Protocols](protocol-and-data-formats.md), [processes](process-and-reconstruction.md) | [Protocol](../assets/templates/protocol-study.yaml) | Reassembly, session state, schema evidence, keys and attribution controls |
| Kernel/drivers, host traces, eBPF and GPU code | [Platforms](platform-and-kernel.md) | [Trace](../assets/templates/platform-trace.yaml) | Symbols, privileges, probe coverage, ISA/IR version and device bindings |
| Packers, instruction snippets and binary rewriting | [Transformations](binary-transformations.md) | [Transformation](../assets/templates/binary-transformation.yaml) | Recovered loader state, format preservation, relocations and signatures |
| Fuzzing, protocol testing, constraints and taint | [Testing](testing-and-constraints.md) | [Campaign](../assets/templates/fuzz-campaign.yaml), [path](../assets/templates/path-query.yaml) | Harness/reset correctness, model completeness, actual target coverage and replay |
| Software inventories, capability leads and version matching | [Matching](matching-and-runtime-artifacts.md) | [Comparison](../assets/templates/comparison-inventory.yaml) | Identification confidence, static libraries, heuristic matches and unmatched scope |
| System memory, crashes and recorded execution | [Runtime artifacts](matching-and-runtime-artifacts.md), [native](native-and-artifacts.md) | [Memory/replay](../assets/templates/memory-replay.yaml) | Acquisition gaps, symbols, host support and recorded schedule |
| EVM and other contract execution formats | [EVM](native-and-artifacts.md), [custom VM](virtual-machines.md) | [VM](../assets/templates/virtual-machine-study.yaml) | Runtime/fork, storage and proxy context; other VMs need an explicit decoder |
| Reconstruction and behavioral equivalence | [Process/reconstruction](process-and-reconstruction.md) | [Cases](../assets/templates/test-cases.csv), [finding](../assets/templates/finding.md) | Finite obligations, comparable environments and untested cases |

## Coverage assessment procedure

1. Enumerate the representations actually present, including embedded native modules, bytecode, resources, remote dependencies and firmware partitions. Source-language labels alone do not establish these boundaries.
2. Map each required question to a result, engine, evidence source and falsifiable check. Mark routes as documented, engine available, fixture checked, target checked, partial, unavailable or out of scope as appropriate. These states are recorded independently, not collapsed into a tool count.
3. Check boundary crossings: file to load address, language to native ABI, application to kernel, firmware to peripheral, capture to message, static candidate to runtime observation, and original to reconstructed behavior.
4. Resolve the smallest missing capability that blocks the result. This may need another engine, a narrow parser/adapter, a capture, a compatible device, or an unavailable vendor schema. Record unsuccessful probes and their reasons.
5. Deliver supported findings and the exact unresolved scope. A row becomes target-checked only after its actual check succeeds on an identified target. A documented fallback may intentionally produce a narrower result.

## Extending an unsupported target

A useful extension includes identification rules, supported format/version/architecture, an authoritative tool or format source, a bounded procedure, output coordinates, representative success/failure fixtures, and a concrete check. A speculative tool name or claimed language support is insufficient. Keep experimental and discontinued tools labeled and reevaluate their suitability when selected.

Encrypted or inaccessible artifacts, unavailable hardware, missing runtime state and unsupported proprietary VMs remain explicit acquisition/interpretation gaps. The same approach applies to newly encountered languages or instruction sets without implying an implementation exists already.
