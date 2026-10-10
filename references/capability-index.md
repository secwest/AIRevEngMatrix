# Result capability matrix

Each row maps an analysis question to a starting toolkit, expected output, and a check that can falsify an incorrect result. The named tools are examples, not prerequisites or evidence that an engine is installed. Additional components address gaps left by the initial analysis.

The [operation catalogue](operation-catalog.md) decomposes these outcomes into individual primitives, including navigation, annotations, device mutations, execution coverage, lifecycle operations, and record management.

## Static artifacts and code

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Identify an unknown file or package | Magic/header reader, file hash, bounded container listing | Format, architecture, member inventory and likely entry points | Header and member ranges fit the original bytes | [Native/artifacts](native-and-artifacts.md) |
| Extract files from an archive, app or firmware | Format-aware extractor, path validation, hashes | Extracted tree with parent paths and digests | No output escapes destination; child digest matches extraction | [Native/artifacts](native-and-artifacts.md), [firmware](firmware.md) |
| Explain native binary layout | ELF/PE/Mach-O parser or LLVM platform tools | Sections, segments, imports, exports, relocations and mitigations | File-backed mapping round trips; memory-only ranges remain distinct | [Native/artifacts](native-and-artifacts.md) |
| Find a function, string or reference | Native analyzer API, symbol/string index | Exact address and source reference locations | Inspect decisive instruction or data bytes | [Native/artifacts](native-and-artifacts.md) |
| Explain a native function or call path | Disassembler/decompiler plus bounded call/reference search | Function dossier, supported path and unresolved dispatch | Compare decisive pseudocode to instructions and call sites | [Native/artifacts](native-and-artifacts.md) |
| Explain native data or dispatch | Type metadata, Objective-C/Swift metadata, cross-references | Type layout, selector or vtable target candidates | Check metadata identity and actual call instructions | [Native/artifacts](native-and-artifacts.md) |
| Analyze packed or transformed code | Container/signature inventory, entropy map, controlled runtime dump when authorized | Packed regions, transformation chain and recovered bytes | Rehash each stage; confirm recovered format and entry point | [Native/artifacts](native-and-artifacts.md) |
| Inspect Apple app resources and signing | Plist, nib/storyboard, asset and signature tools | Bundle metadata, UI wiring, assets, entitlements and signature result | Resolve referenced resource IDs and signing subject | [Native/artifacts](native-and-artifacts.md) |
| Inspect an iOS/macOS application package | Archive/bundle inventory, plist, Mach-O and resource tools | Bundle identity, code modules, entitlements, resources and entry points | Match package metadata to contained executable digests | [Native/artifacts](native-and-artifacts.md) |
| Explain a recorded crash | Core/minidump/crash parser and matching symbols | Fault, threads, registers, stack and module map | Match build IDs before symbolization | [Native/artifacts](native-and-artifacts.md) |
| Infer an EVM contract interface | Strict bytecode decoder and EVM disassembler | Selector and event candidates with entry offsets | Confirm dispatch paths in decoded instructions | [Native/artifacts](native-and-artifacts.md) |
| Inspect a .NET assembly | CLI metadata/CIL parser | Types, signatures, CIL, calls and native declarations | Resolve a known token to its signature and body | [Managed/mobile](managed-mobile-firmware.md) |
| Inspect Android package code/resources | ZIP, manifest/resources, DEX parser or JADX/Apktool | Components, resource IDs, classes, methods and references | Trace decoded values back to APK members/DEX IDs | [Managed/mobile](managed-mobile-firmware.md) |
| Identify a firmware image or flash dump | Hash, header parser, bounded entropy/signature scan | Provenance, format candidates, byte ranges, architecture clues and unknowns | Confirm header fields, sizes and offset coordinate system against raw bytes | [Firmware](firmware.md) |
| Recover firmware components | Region map and format-specific extractor | Partition/component map, child bytes and parent offsets | Check boundaries, checksums and filesystem structure; preserve overlaps and gaps | [Firmware](firmware.md) |
| Reconstruct a boot chain | Boot metadata, image/partition parser, kernel/DTB or vector analysis | Stage handoffs, addresses, root selection and trust dependencies | Resolve each referenced image and address; distinguish configured from observed boot | [Firmware](firmware.md) |
| Explain an embedded service | Rootfs/service inventory and native analyzer | Startup path, executable/config, listener and handler | Verify service linkage and decisive code path; observe when reachability matters | [Firmware](firmware.md) |
| Explain MCU or RTOS behavior | Memory map, disassembler, vector/interrupt and task analysis | Reset-to-feature path, hardware accesses and event contexts | Check load base against multiple references and ISR/task boundaries | [Firmware](firmware.md) |
| Inspect UEFI or PC firmware | Capsule/SPI and firmware-volume parser, PE analyzer | Regions, modules, boot-phase relationships and update metadata | Resolve GUID/section boundaries and dependency path; separate payload from installed layout | [Firmware](firmware.md) |
| Analyze firmware update policy | Manifest/signature parser and verifier-path analysis | Board/version gates, signature scope, slot and rollback behavior | Separate package claims from checks in code and effects observed on hardware | [Firmware](firmware.md) |
| Reconstruct an incremental firmware update | Payload decoder, exact base image and partition/extent metadata | Reconstructed partitions, required-base identities and unresolved operations | Verify base and output digests and extent bounds; missing inputs remain explicit | [Firmware](firmware.md) |
| Recover JavaScript application structure | Container/ASAR reader and JS AST parser | Entry points, modules, exports, routes, IPC and endpoints | Resolve a known import or handler across files | [JavaScript/web](javascript-and-web.md) |
| Recover readable JavaScript source | Source-map decoder, formatter or recovery engine | Mapped originals or explicitly inferred modules | Check a known generated-to-original span | [JavaScript/web](javascript-and-web.md) |
| Locate a feature in bundled source | AST import/call search and source maps | Behavior chain with generated and original locations | Verify each import/call/IPC link | [JavaScript/web](javascript-and-web.md) |

## Runtime and device behavior

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Observe native calls or UI actions | Debugger/tracer and accessibility/window API | Ordered calls, UI elements, selected arguments and timing | Correlate module identity and load slide; report attach gap | [Native/artifacts](native-and-artifacts.md) |
| Inspect an Android device or acquire an app | ADB client with explicit serial | Device/package identity, files/APKs, logs or screen | Verify pulled bytes and package/split completeness | [Managed/mobile](managed-mobile-firmware.md) |
| Observe firmware or device behavior | Passive capture, supported board emulator or authorized hardware probe | Boot/service events with configuration and capture window | Repeat a controlled condition; state missing peripherals or instrumentation effects | [Firmware](firmware.md) |
| Inspect a live web page | CDP target selection and bounded page snapshot | DOM/accessibility, scripts, resources and selected metadata | Record target ID, enabled domains and attach window | [JavaScript/web](javascript-and-web.md) |
| Observe a web interaction | CDP event capture over a defined window | Navigation, requests, console, exceptions and event order | Confirm capture coverage and loss counters | [JavaScript/web](javascript-and-web.md) |
| Reproduce a browser or Electron scenario | Playwright or equivalent action harness | Step outcomes, final state, screenshots and selected traffic | Assert a concrete final condition; replay a fixture | [JavaScript/web](javascript-and-web.md) |
| Inspect Node/Electron execution | V8 Inspector or Electron DevTools | Loaded scripts, contexts, windows, selected IPC/runtime events | Match runtime script identity to shipped bytes | [JavaScript/web](javascript-and-web.md) |
| Explain recorded network behavior | HAR/CDP/mitmproxy capture parser | Request/response pairs, redirects, timings and payload availability | Check IDs, redirect chain and capture omissions | [JavaScript/web](javascript-and-web.md) |
| Reconstruct messages from a packet capture | Wireshark/TShark or bounded PCAP/PCAPNG parser with transport reassembly | Directional messages linked to packets, gaps and capture settings | Check retransmissions, framing and missing ranges; incomplete streams remain partial | [Process/comparison](process-and-reconstruction.md) |
| Describe a process or protocol run | Process/PTY harness and selected network or filesystem capture | Input/output sequence, exit state and externally visible effects | Repeat a known fixture and state normalization rules | [Process/comparison](process-and-reconstruction.md) |
| Infer a network protocol | Authorized traffic capture, message framing and state comparison | Message fields, direction, sequence and error behavior candidates | Replay a small controlled fixture and vary one input at a time | [Process/comparison](process-and-reconstruction.md) |
| Assess remote fingerprintability | Authorized black-box probes or existing captures | Observable features, conditions, stability and confidence | Repeat across sessions/versions and compare against controls | [Process/comparison](process-and-reconstruction.md) |
| Assess firmware remote fingerprintability | Service path plus authorized captures or probes | Reachable protocol signals tied to a specific build/configuration | Confirm listener, request preconditions and repeatability across controls | [Firmware](firmware.md), [process/comparison](process-and-reconstruction.md) |

## Differences and reconstruction

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Compare two artifacts or packages | Digests, member manifests, format parsers | Exact, structural and unmatched changes | Identical-input comparison returns no changes | [Process/comparison](process-and-reconstruction.md) |
| Compare firmware releases | Paired partitions, filesystem manifests, code/config diff | Changed components and plausible behavior changes | Match component roles and architecture; keep unmatched regions explicit | [Firmware](firmware.md) |
| Compare functions or managed members | Stable identity matching and normalized code | Changed instructions/IL, signatures and call edges | Expose ambiguous and moved matches | [Native/artifacts](native-and-artifacts.md), [managed/mobile](managed-mobile-firmware.md) |
| Compare browser captures or screenshots | Compatible capture settings and diff logic | Changed events, states or pixels with coverage caveats | Repeated deterministic fixture yields no unexplained diff | [JavaScript/web](javascript-and-web.md) |
| Identify changed behavior between versions | Matched static traces plus comparable runtime scenarios | Supported behavior difference and remaining candidates | Trace each claimed change to source and observation | [Process/comparison](process-and-reconstruction.md) |
| Check a reconstruction | Original fixture/capture, rebuilt target and comparator | Passing, failing, missing and incomparable cases | Run same cases with declared normalization | [Process/comparison](process-and-reconstruction.md) |
| Explain a cross-layer feature | Relevant static and runtime analyzers | User-visible path through UI, code, IPC, native or network layers | Verify each boundary with identity and source location | [Process/comparison](process-and-reconstruction.md) |

## Firmware experiments and hardware

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Acquire supported flash or MCU memory | flashrom or pyOCD with matching programmer/probe | Original dumps, target/connection record and acquisition gaps | Compare repeated reads and expected ranges; record attach/reset effects | [Firmware lab](firmware-lab.md) |
| Reproduce firmware behavior with modeled dependencies | Renode or Qiling with a compatible environment | Minimal harness, traces, substitutions and model gaps | Repeat from defined state and compare a fixture or hardware trace | [Firmware lab](firmware-lab.md) |
| Decode hardware signals | sigrok/PulseView or sigrok-cli and supported instrument/decoder | Raw capture plus transactions linked to samples | Check decoded fields against raw edges and known device state | [Firmware lab](firmware-lab.md) |
| Interpret CAN traffic | cantools, capture and identified database | Frame/signal records, scaling and field hypotheses | Check frame flags, multiplexing, raw bytes and independent known states | [Firmware lab](firmware-lab.md) |

## Systematic testing and constraints

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Find and reproduce parser/runtime failures | AFL++ plus compatible instrumentation and a resettable harness | Corpus, campaign scope and replayable failures | Confirm target coverage, baseline behavior and minimized-case replay | [Testing](testing-and-constraints.md) |
| Test stateful protocol handling | boofuzz plus session/reset/monitor model | Message sequences, failure classifications and reproducers | Reestablish baseline and replay the complete prerequisite sequence | [Testing](testing-and-constraints.md) |
| Find an input satisfying a code-path condition | angr plus explicit initial state and finite constraints | Witness or scoped unsat/exhausted/timeout outcome | Replay witness on concrete target and check the decisive branch | [Constraints](testing-and-constraints.md) |
| Explain input influence along execution | Triton with a concrete driver and taint policy | Source-to-sink dependencies anchored to instructions | Change a selected source byte and check the predicted effect | [Constraints](testing-and-constraints.md) |

## Additional formats and runtime artifacts

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Recover a proprietary binary format | Byte map, samples and Kaitai Struct | Format specification and bounded parser | Known fields, malformed lengths, truncation and exact-consumption fixtures | [Formats](formats-and-runtimes.md) |
| Inspect WebAssembly modules or components | wasm-tools and embedding application context | Validated structure, instruction/interface records and host boundaries | Record enabled features and check function indices/import bindings | [Runtimes](formats-and-runtimes.md) |
| Explain a JVM class or JAR feature | Class/archive inventory and Vineflower | Descriptor-anchored methods, reconstructed code and dynamic gaps | Check decisive bytecode and selected runtime class variant | [Runtimes](formats-and-runtimes.md) |
| Inspect Python bytecode | Container extractor where needed and xdis | Version-qualified instructions and code-object relationships | Match magic/version and preserve bytecode offsets; do not import modules | [Runtimes](formats-and-runtimes.md) |
| Recover Go runtime metadata | GoReSym and native analyzer | Available names, types, source mappings and function ranges | Check representative boundaries and load-address translation | [Runtimes](formats-and-runtimes.md) |
| Match functions across builds | Diaphora and compatible IDA exports | Matches, changes, ambiguous and unmatched functions | Inspect decisive instructions on both sides; preserve heuristic uncertainty | [Matching](matching-and-runtime-artifacts.md) |
| Inventory firmware/software components | Syft over identified extracted tree or supported image | Scoped inventory/SBOM with evidence paths | Check representative identities; preserve unrecognized/static code | [Inventory](matching-and-runtime-artifacts.md) |
| Find capability and decoded-string leads | capa and/or FLOSS on supported inputs | Located candidates with rule/extraction provenance | Inspect decisive code/decoding and record coverage warnings | [Discovery](matching-and-runtime-artifacts.md) |
| Explain runtime state from system memory | Volatility 3 with compatible layers/symbols | Selected process/module/memory artifacts | Check build/symbol identity and decisive raw structures | [Memory](matching-and-runtime-artifacts.md) |
| Find the earlier event causing a process failure | rr on a supported Linux host and debugger | Replayable recording and causal event explanation | Replay a known event and preserve trace dependencies | [Replay](matching-and-runtime-artifacts.md) |

## Language recovery, VMs, platforms, and specialist targets

For language-specific recovery, use the [development-environment workflows](development-environments.md) to select an actual decompiler effort, interpret lowered constructs and define the representative check. The [environment study](../assets/templates/environment-study.yaml) records compiler/runtime and reconstruction outcomes.

| Analysis question | Starting components | Result | Check | Method |
| --- | --- | --- | --- | --- |
| Choose a decompiler for a language/compiler | Representation inventory, support probe, compatible native/VM engine | Selected engine and supported output kind | Inspect a representative body and preserve unsupported constructs | [Languages](language-decompilation.md) |
| Explain Rust types, error paths, traits or async lowering | Native analyzer, Oxidizer/angr where supported, Rust symbols/metadata | Instruction-anchored layout and behavior hypotheses | Check ABI, discriminants/niches, dispatch and cleanup against the selected build | [Rust](rust-reverse-engineering.md) |
| Explain C++ inheritance, dispatch or exceptions | Native analyzer with ABI, RTTI/vtable and unwind metadata | Dispatch/type candidates and normal/exception paths | Confirm object adjustments, call targets and landing pads | [Languages](language-decompilation.md) |
| Decompile Python, Lua, JVM or CLR bytecode | Exact format/version and matching decompiler | Supported source-like code and unreconstructed bodies | Compare decisive bytecode, stack behavior and exception ranges | [Languages](language-decompilation.md), [VMs](virtual-machines.md) |
| Analyze Flutter or Unity IL2CPP | Blutter or Cpp2IL/Il2CppDumper plus native analyzer | Metadata-to-code bindings and method interpretations | Match build, architecture, metadata version and actual body bytes | [VMs](virtual-machines.md) |
| Inspect Hermes, BEAM, SWF or a legacy VM | Compatible bytecode/debug-info reader | Functions, constants, interfaces and supported decompilation | Check container version and instruction boundaries; retain absent source/debug data | [VMs](virtual-machines.md) |
| Recover a custom VM's semantics | Dispatch analysis and bounded instruction decoder | Documented instruction subset, state transitions and checked decoder | Differential known-input cases; unknown opcodes stop or remain explicit | [VMs](virtual-machines.md) |
| Explain a JIT specialization | Compatible runtime introspection and generated code/IR mapping | Selected method/type behavior and native boundaries | Match runtime, compilation context, code lifetime and concrete cases | [VMs](virtual-machines.md) |
| Trace an OS process, kernel subsystem or driver | Platform tracer/debugger and matching symbols | Event/state explanation with module and process identities | Positive control, capture loss, ABI and event-window checks | [Platform](platform-and-kernel.md) |
| Explain eBPF, GPU or shader behavior | bpftool/LLVM, NVIDIA utilities or SPIRV-Tools | Versioned instructions, bindings and host/device boundaries | Preserve ELF/IR/translated/JIT distinctions and check selected accesses | [Platform](platform-and-kernel.md) |
| Interpret peripheral registers or RTOS objects | Exact device SVD and RTOS build/layout data | Located registers, tasks, interrupt and scheduler relationships | Check part revision, register side effects, type offsets and initialization | [Firmware specialties](firmware-specializations.md) |
| Explain a firmware isolation boundary | Boot/configuration records, native analysis, controlled observations | Secure/nonsecure, privilege or guest/host crossing and enforcement evidence | Follow validation and access-control decisions on both sides | [Firmware specialties](firmware-specializations.md) |
| Decode raw NAND, UBI/JFFS2 or ACPI tables | Geometry-aware MTD/UBI tools, Jefferson or ACPICA | Logical files/table interpretation with original coordinates | Check ECC/OOB/bad blocks or table identity/checksum and AML mappings | [Firmware specialties](firmware-specializations.md) |
| Explain USB, Bluetooth or RF captures | Layer-appropriate capture decoder and device/radio context | Transactions, sample-derived signals and unresolved layers | Check known stimuli, channels, time base and capture-layer limits | [Firmware specialties](firmware-specializations.md) |
| Recover a hardware-observed execution path | Compatible trace capture, OpenCSD and exact code image | Supported instruction ranges/events with raw trace references | Check source protocol, synchronization, overflow and a known marker/branch | [Hardware trace](firmware-specializations.md) |
| Inspect FPGA or industrial controller artifacts | Compatible netlist/HDL or vendor/runtime decoder | Supported logic/task/state explanation | Require exact family/format and compare simulation or known controller states | [Firmware specialties](firmware-specializations.md) |
| Compare physical measurements with firmware behavior | Compatible instrument, repeatable stimulus and synchronized capture | Measured response and hypotheses with controls | Check calibration, baseline, repetition and trigger alignment | [Firmware specialties](firmware-specializations.md) |
| Unpack or rebuild a binary copy | Identified transform, file-format editor/assembler, native checker | Separate output and explicit transformation map | Validate preconditions, relocation/integrity effects and selected behavior | [Transformations](binary-transformations.md) |
| Execute a bounded instruction snippet | Unicorn or equivalent plus explicit CPU/memory model | Registers, writes and completion reason | Check instruction support and known cases; retain missing OS/device behavior | [Transformations](binary-transformations.md) |
| Recover message framing, schemas or protocol state | Scapy/TShark, matched schema tools, varying captures | Checked message model and replay cases | Check reassembly, lengths, checksum hypotheses, independent states and negative cases | [Protocols](protocol-and-data-formats.md) |
| Assess investigation coverage | Target inventory and required method boundaries | Documented/available/fixture-checked/target-checked scope and gaps | Every required claim has a falsifiable check or an explicit unresolved dependency | [Coverage](coverage-map.md) |

## Supporting structures

A one-off result can consist of the finding and decisive source locations. [Graph and evidence conventions](evidence-and-runtime.md) support results combined across versions or layers, exported for audit, queried repeatedly, or tracked as reconstruction obligations. A graph, evidence bundle, or session service supports the finding; it does not replace it.

[Analysis templates](templates.md) provide optional working records for these workflows and a concise result format. They distinguish planned procedures from recorded observations.
