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

## Supporting structures

A one-off result can consist of the finding and decisive source locations. [Graph and evidence conventions](evidence-and-runtime.md) support results combined across versions or layers, exported for audit, queried repeatedly, or tracked as reconstruction obligations. A graph, evidence bundle, or session service supports the finding; it does not replace it.
