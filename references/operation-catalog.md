# Analysis operation catalogue

This catalogue specifies individual analysis operations. Related primitives share rows where their implementation and checks are similar. The names are descriptive selectors for building a toolkit; they do not imply an installed API or executable implementation.

Each row gives the input and method, the expected result, and a check or limit that changes the interpretation. The linked family method supplies common acquisition, engine selection, coordinate, and validation rules. Operations can be composed directly from an existing API or CLI; an adapter is needed only for missing integration.

## Shared result contract

A result carries target identity, selected input/selector, producer and version, source locations or raw-output references, completeness, and typed errors or limitations. Lists declare their ordering, range conventions and pagination. A cap produces an explicit partial result or resource error. Mutation results identify the changed state, readback, persistence scope, and cleanup or rollback outcome.

Static facts, engine interpretations, runtime observations, and analyst annotations retain distinct authority. Engine/host support determines availability. A requested operation can remain unavailable even when its specification is complete.

## Native code and navigation

Method: [Native code and navigation](native-and-artifacts.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `address_name` | Artifact identity and exact address; query the analyzer's primary symbol. | Name or explicit absence, with the queried coordinate. | An alias is not silently substituted for the primary symbol. |
| `comment`, `inline_comment` | Artifact, address, and regular or inline comment channel. | Stored analyst text or absence; preserve the channel. | Comments remain analyst annotations, distinct from recovered bytes. |
| `current_address`, `current_procedure`, `current_document` | An explicitly selected interactive analysis session. | Observed cursor, containing procedure, or selected document identity. | Unavailable GUI state stays unavailable on a headless engine. |
| `goto_address`, `next_address`, `prev_address` | Mapped destination or current object plus direction; use engine navigation. | Observed cursor or adjacent analyzed object, including any snapping. | Object order does not imply instruction flow; failed navigation reports its effect. |
| `list_bookmarks`, `list_documents` | Selected analyzer and optional document. | Bookmark address/name pairs or open program identities. | Preserve unnamed bookmarks and distinguish program identities. |
| `list_names`, `list_procedures`, `list_segments`, `list_strings` | Selected immutable artifact and analyzer inventories. | Symbols, function entries, memory blocks, or typed strings with supported metadata. | Expose range conventions, decoding gaps, external symbols, and incomplete inventories. |
| `procedure_address`, `resolve_containing_procedure` | Exact symbol/entry selector or arbitrary address, respectively. | Canonical function entry or actual containing function; ambiguous/absent outcomes. | Containment follows body ranges, never the nearest symbol. |
| `procedure_assembly`, `read_function_instructions` | Canonical function identity; query text assembly or instruction records. | Assembly text or address/bytes/mnemonic/operand records with coverage. | Retain engine syntax and exact addresses; report undecodable spans. |
| `procedure_callees`, `procedure_callers`, `procedure_references`, `xrefs` | Function or code/data address and requested direction. | Resolved call neighbors or incoming/outgoing reference records. | Preserve call-site addresses and edge types when available; indirect gaps stay explicit. |
| `procedure_info` | Canonical function identity and analyzer metadata. | Signature, locals, entry, body ranges, sizes, and block count where supported. | Body byte count and enclosing span differ; unavailable types and extents stay unknown. |
| `procedure_pseudo_code`, `batch_decompile` | One function or an ordered list; select an available decompiler. | Producer pseudocode with canonical identity and per-item success/failure. | Preserve input order and usable partial results; pseudocode is not original source. |
| `search_procedures`, `search_strings` | Literal query or explicit regex, artifact, and search domain. | Stable matching functions or typed strings with source identities. | Literal matching is the default; regex evaluation is bounded and cancellable. |
| `read_bytes`, `address_to_file_offset` | Address plus length for reads; exact image map for translation. | Returned bytes/length or a file offset and mapping basis. | Separate changed sources, partial reads, memory-only ranges, and unmapped addresses. |
| `set_address_name`, `set_addresses_names` | One or several address/name assignments in a writable database. | Per-address edit and readback result. | Validate ownership/collisions first; moves/swaps are explicit and partial failures visible. |
| `set_comment`, `set_inline_comment` | Exact address, channel, and replacement text. | Readback result; empty text clears the selected channel. | Report engine normalization and persistence scope. |
| `set_bookmark`, `unset_bookmark` | Exact address and optional bookmark name. | Created/replaced bookmark or confirmed absence. | Verify the requested navigation metadata without implying a binary modification. |
| `annotate_native_function` | Function identity and a grouped rename/comment change. | Refreshed function facts and mutation outcome. | Validate before mutation; rollback on failure when supported, otherwise expose partial state. |
| `inspect_native_load_image` | Original DOS MZ or explicitly identified COM bytes and loaded analyzer image. | Source/loaded digests, segment mappings, relocations, entry state, mismatches. | Document imposed COM context, overlays, and uninitialized gaps; no runtime coverage claim. |
| `inspect_native_data_type` | Exact database type path or typed address. | Size, packing, alignment, fields, bitfields, enums, and child type IDs. | Keep recovered types and uncertain source-language meaning distinct. |
| `inspect_native_instruction`, `resolve_native_call_targets` | Exact instruction or call-site address. | Decoded instruction/typed references or resolved/ambiguous/unresolved callees. | Distinguish data and interior addresses; computed targets require evidence. |
| `analyze_function` | Canonical function identity; join the relevant analyzer primitives. | Function dossier: code, ranges, comments, calls, references, strings, local CFG, gaps. | Every facet retains the same artifact/provider identity. |
| `inspect_native_api` | Function containing an API or dispatch boundary. | Signature/argument evidence, jump-table cases and separately evidenced default target. | Unknown case values are not default cases; unsupported branches remain visible. |
| `inspect_native_dispatch_metadata`, `get_objc_classes`, `get_objc_protocols`, `analyze_swift_types` | Objective-C/Swift symbols and available metadata, optional filter. | Class/protocol/type candidates or categorized symbol records. | Separate labels and manglings from decoded runtime layouts and source-type counts. |
| `get_call_graph`, `trace_call_path`, `build_call_path` | Root and optional goal; live analyzer edges or existing function dossiers. | Bounded caller/callee graph or shortest supported path(s). | Report caps, missing dossiers, provider mixing, and unresolved edges; no feasibility claim. |
| `find_xrefs_to_name`, `trace_feature` | Exact name or literal feature query; search symbols/strings then references. | Name resolution or a supported feature lead through containing functions. | Preserve the full query and distinguish unresolved names from an empty reference set. |
| `binary_overview` | Artifact metadata and completed analyzer inventories. | Architecture/layout summary and scoped function/string counts. | Counts refer to the analyzed inventory and its coverage. |
| `trace_native_ui_action` | UI connection, object ID, symbol, or exact handler address. | Authored UI connection to handler and supported static call edges. | Label unresolved handlers and inferred links; a static path does not prove activation. |
| `trace_native_values` | Function and bounded data-flow query; analyzer IR/SSA or justified trace. | Def-use graph with constants, operators, memory/branch effects, argument and return bindings. | Keep aliasing, persistent-state, and missing interprocedural bindings explicit. |

## Artifacts, Apple applications, and native runtime

Method: [Artifacts, Apple applications, and native runtime](native-and-artifacts.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `inspect_artifact`, `extract_artifact` | Package/archive and integrity policy; a fresh destination for extraction. | Member inventory or extracted regular files, digests, metadata, and integrity failures. | Preserve unexplored branches; validate paths and declared integrity, and report partial recovery. |
| `inspect_macho`, `list_architectures` | Exact thin/universal Mach-O bytes and optional slice. | Slices, headers, commands, imports/exports, dependencies, ranges, permissions. | Validate slice boundaries and distinguish original-file from slice coordinates. |
| `inspect_signature`, `inspect_plist` | Selected artifact/signature or explicit plist. | Signing facts and verification result, or normalized plist plus source identity. | Signing does not establish software trust; preserve unsupported plist values. |
| `demangle_swift` | Ordered single-line symbol strings and installed demangler. | One demangled/unchanged/invalid outcome per input. | Preserve original symbols and order; names alone do not prove type layout. |
| `decode_interface_builder` | Compiled nib/storyboard members and bounded parser. | Object hierarchy, outlets/actions, connection IDs, and unresolved handlers. | Preserve object identities and unknown classes without executing archive content. |
| `inspect_keyed_archive` | Selected NSKeyedArchiver plist, root, and object page. | Original object table, class descriptors, roots, UID edges, cycles and shared references. | Do not instantiate archived classes or flatten away reference identity. |
| `inspect_asset_catalog` | Selected Assets.car and metadata decoder. | Catalog/rendition records with source digest and raw decoder fields. | Metadata inspection does not imply rendition-byte extraction. |
| `trace_dylib_resolution` | Mach-O executable roots, architecture, loader paths and rpath context. | Ordered candidate paths, dependency flags, resolved in-scope images and unknown external paths. | Keep each process's loader context; a static candidate is not an observed library load. |
| `inspect_pe_resources`, `inspect_binary_layout` | Bounded PE resource or supported executable parser. | Resource hierarchy/payload digests or sections, symbols, relocations and mitigation facts. | Validate raw ranges and distinguish derived/static conclusions from runtime state. |
| `inspect_recorded_crash` | Recorded core/minidump/crash and explicitly matched symbols if supplied. | Notes, fault state, threads/registers, maps, stacks and symbol provenance. | Recorded PIDs and core-only mapping candidates do not establish current host identity. |
| `observe_native_ui` | Exact running process/window and permitted accessibility/screenshot APIs. | Bounded accessibility tree and window image tied to the target. | Permission failure does not broaden capture to another window. |
| `capture_native_ui_scenario` | Exact window plus selected-element actions and bounded waits. | Ordered actions, before/after UI states, captures, and failures. | Verify window identity through steps; record state changes and restoration policy. |
| `observe_native_calls` | Authorized launch/attach mode, selected functions, debugger and event/time caps. | Function-entry events, thread/module/address, ABI-specific register/argument observations. | Symbol breakpoints, attach gaps, lost hits, ownership and termination remain explicit. |
| `inspect_evm_interface` | Explicit raw/hex carrier, bytecode format and supported decoder. | Carrier/decoded hashes, dispatch selectors, argument/mutability/event candidates. | Preserve unsupported formats and fork assumptions; no deployment authenticity from local bytes. |

## Managed code, Android packages, and JEB

Method: [Managed code, Android packages, and JEB](managed-mobile-firmware.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `inspect_managed_artifact`, `inspect_managed_members`, `inspect_managed_native_boundaries` | Exact assembly bytes and CLI metadata/CIL parser. | Assembly/module identities, members/signatures/code or native-boundary declarations. | Tokens are build-local; no assembly loading or inferred runtime native binding. |
| `compare_managed_members` | Two member inventories with signatures and instruction/exception structure. | Unique matches, changes, ambiguous and unresolved members. | Normalize token references with mappings; undecoded signatures cannot support definite absence. |
| `verify_managed_native_boundaries` | Managed declarations and native exports/functions from identified artifacts. | Verified, inferred, contradicted, declaration-only and unresolved boundaries. | Match library, symbol/ordinal, architecture and ABI; never cast a metadata token to an address. |
| `import_managed_reconstruction` | Decompiler output and exact original member inventory. | Recreated-member mappings bound to artifact, module, token and signature/code identity. | Reject ambiguous bindings and record decompiler/options; source remains reconstruction. |
| `project_managed_application_graph` | Artifact, member and native-boundary records. | Typed managed nodes/edges with source references. | Preserve declaration authority and original member identities. |
| `inspect_android_package` | Exact APK, manifest/resources/DEX engine. | Package/SDK/permission facts, resources/classes and coverage. | Separate decoding, decompilation, and signature verification. |
| `search_android_classes`, `inspect_android_class` | APK plus class-name query or exact class selector. | Matching classes or selected methods, fields and inner classes. | Retain artifact/engine identity and synthetic members; display names may lack exact DEX descriptors. |
| `inspect_android_method`, `trace_android_references` | Exact class/method identity including overload disambiguation. | Method representation or incoming static references, with source/bytecode locations when known. | Mark smali fallback, truncation and unsupported overload-reference queries. |
| `inspect_apktool_client`, `decode_android_resources` | Selected launcher; APK and optional locale for decode. | Version/availability or decoded manifest, resources, locales, and diagnostics. | Separate resource decode from source recovery; preserve digest and temporary-output lifecycle. |
| `inspect_jeb_client`, `open_jeb_project` | Selected licensed engine; artifact/database path on its host when opening. | Client version/mode or project identity, input digests and top-level units. | Keep engine-host paths distinct from local paths and report existing-project conflicts. |
| `list_jeb_units`, `decompile_jeb_item` | Project/unit selector, pagination or exact item address. | Stable unit paths/types or producer pseudocode. | A full capped page may be partial; omitted selectors cannot imply known item identity. |

## Android device operations

Method: [Android device operations](managed-mobile-firmware.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `inspect_adb_client`, `list_adb_devices`, `inspect_adb_device` | Selected ADB binary, then explicit serial where needed. | Client identity, device/state list or bounded build properties. | Record server startup, serial/state, permissions and source of each field. |
| `list_adb_packages`, `inspect_adb_package`, `resolve_adb_packages` | Device serial and scope, package ID, or package search. | Package paths/identities, version/install facts or exact candidates. | Device paths differ from host paths; ambiguous package matches remain choices. |
| `pull_adb_package`, `pull_adb_file` | Device serial, package or absolute device path, fresh local destination. | Base and all splits, or requested file, with digests and per-file outcomes. | Record incomplete pulls; compare remote identity/digest when available. |
| `push_adb_file` | Local source/digest, device serial and explicit destination. | Transfer outcome and available destination verification. | State overwrite behavior and path semantics; a successful command alone may lack content verification. |
| `read_adb_logcat`, `collect_adb_bugreport` | Device, selected log scope/count or diagnostic collection. | Bounded logs or bugreport artifact with capture metadata. | Preserve truncation/collection effects and redact selected sensitive values in reports. |
| `capture_adb_screen`, `inspect_adb_display`, `inspect_adb_window` | Exact device and supported screenshot/display/window query. | PNG or structured display/window observations. | Verify image bytes/dimensions; version-dependent missing fields remain unknown. |
| `list_adb_processes`, `list_adb_directory`, `list_adb_features`, `list_adb_services`, `read_adb_setting` | Device serial and explicit directory/setting or inventory selector. | Selected process/file/feature/service/setting records. | Bound output; distinguish denied access, absent values and unsupported output formats. |
| `install_adb_package`, `uninstall_adb_package` | Explicit local APK set or installed package; device and requested install/remove options. | Per-operation outcome and resulting package/version state. | Account for split consistency, user/profile and data retention/removal semantics. |
| `start_adb_app`, `start_adb_activity`, `stop_adb_app` | Device, exact package or activity/intent selector and requested action. | Launch/stop outcome and observable process/activity state. | Use device-shell-safe encoding; report external effects and failed postconditions. |

## Firmware

Method: [Firmware](firmware.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `inspect_firmware_regions`, `extract_firmware` | Immutable image and bounded scanner/parser; selected ranges and extraction destination. | Validated candidate regions or recovered files, transforms, hashes, unknown chunks. | Scanner signatures need confirmation; decompressed coordinates keep their transformation map. |

## JavaScript and cross-layer application analysis

Methods: [JavaScript](javascript-and-web.md) and [cross-layer application analysis](process-and-reconstruction.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `analyze_javascript_application` | ASAR, directory or acquired script set; syntax-aware parser and format inventory. | Modules, imports, exports, handlers, semantic facts, assets and coverage. | Validate member identity, integrity and external files; do not execute source. |
| `trace_application_feature`, `trace_javascript_semantics` | Exact graph/source seed and direction; bounded relationship or data-flow query. | Supported feature path or value/call/return/closure dependencies. | Dynamic dispatch, aliasing and unsupported semantics remain unresolved. |
| `compare_application_versions`, `compare_source_to_bundle` | Two identified module graphs, or a versioned source snapshot and shipped bundle. | Matches, changes, split/merged/duplicated candidates and unmatched coverage. | Use exact identities first; weak path/name similarity cannot force a match or absence. |
| `compare_javascript_export_shapes` | Exact module/export pair and static return-shape analysis. | Per-variant property presence/value differences with source spans. | Pair variants by unique discriminants; incomplete coverage or dynamic values stay unknown. |
| `project_android_application_graph`, `project_apple_application_graph` | Verified package/member inventory and platform role rules. | Typed package/component nodes, hashes, nested roles and candidate boundaries. | Path conventions establish role hypotheses, not decoded behavior or runtime calls. |
| `reconcile_javascript_runtime` | Static modules and compatible runtime observations plus explicit mappings where needed. | Matched scripts/contexts/targets and unsupported or ambiguous joins. | Prefer byte identity; URL/file names alone do not establish execution or source ownership. |

## Browser, Electron, and JavaScript runtime

Method: [Browser, Electron, and JavaScript runtime](javascript-and-web.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `list_browser_targets`, `list_electron_targets`, `list_javascript_runtime_targets` | Explicit authorized CDP/Inspector endpoint and optional origin/type selector. | Eligible page, Electron, or Node/runtime target identities. | Discovery does not attach; reported URLs may not establish filesystem identity. |
| `inspect_web_page`, `inspect_electron_page` | Exact target ID, endpoint, scope and bounded capture options. | Frames, DOM/accessibility, scripts/resources and available attach-window facts. | Revalidate target identity; no invented pre-attach events or unavailable renderer internals. |
| `observe_web_session`, `observe_javascript_runtime` | Exact page/runtime and time window; subscribe to selected domains. | Lifecycle, console/network or script/context records with coverage. | Passive subscription does not establish calls, IPC, require/import edges, or past execution. |
| `analyze_web_bundle` | Captured source and optionally scoped source-map acquisition. | Chunk/import relationships, routes/endpoints and framework/interface candidates. | Record every fetched input and distinguish literals from interpretation. |
| `discover_webmcp_tools` | Browser exposing a documented tool-discovery interface. | Advertised names, schemas and declaration provenance. | Feature-detect support; declarations are untrusted and do not authorize invocation. |
| `capture_browser_scenario` | Owned or selected browser, environment/storage policy, named actions and deadlines. | Step outcomes, final assertion, selected traffic/storage and screenshots. | Track target/frame identity, explicit body capture, loss and cleanup ownership. |
| `capture_electron_scenario` | Owned Electron executable, controlled launch environment and lifecycle/action sequence. | Window/process/preload/IPC/session/navigation events and action outcomes. | Record blocked external effects, instrumentation limits, cancellation and teardown failures. |
| `capture_web_screenshot`, `compare_web_screenshots` | Selected viewport or two identified PNG artifacts. | Image/digest or pixel difference metrics and dimensions. | Match viewport/scale/state and report rendering nondeterminism; no behavioral equivalence claim. |
| `compare_web_captures` | Two compatible passive captures or scenarios and declared normalization. | Aligned events/steps and changed, missing or incomparable observations. | Never turn truncation, missing bodies, or alignment failure into equality. |
| `observe_web_execution` | Selected page and explicit instrumented coverage window. | Script digests and nested execution ranges/counts tied to that window. | Precise coverage can reset counters/affect optimization; capture arming, navigation and target limits. |
| `inspect_web_event_listeners` | Exact page/document and explicit element selector. | Direct listener flags, callback locations, source identity and unavailable fields. | No dispatch is implied; delegated/framework listeners and execution history may be absent. |
| `export_web_scripts` | Retained script/body bytes in a capture and fresh output directory. | Files plus manifest of URLs, script/event IDs, sizes, digests and unavailable sources. | No silent refetch; isolate URL versions, inline scripts and path collisions. |
| `trace_web_source_location` | Exact exported script, paired source map and generated coordinate. | Supported original positions/text, unmapped spans and mapping provenance. | Verify identities, coordinate units/bases, section support and ambiguous mappings. |
| `trace_web_module_imports` | Identified exported importer, base URL, import map and actual resolution rules. | Outgoing import/re-export spans, resolved URLs, captured candidates and errors. | Preserve queries/fragments; computed imports and bundler IDs remain unresolved when unsupported. |
| `inspect_web_network_capture` | Local HAR or native mitmproxy records and compatible offline decoder. | Record ordinals, producer fields, available payload bytes and capture gaps. | No recorded-URL fetch; text encoding, redaction and missing transport facts remain explicit. |
| `recover_javascript_sources` | Local bundle, nonexecuting recovery engine and fresh output directory. | Readable modules, maps, source ranges, digests and warnings. | Fallback to one module remains visible; readable output is not original-source or runtime equivalence. |

## Process comparison and reconstruction

Methods: [Process comparison and reconstruction](process-and-reconstruction.md) and [bundle comparison](evidence-and-runtime.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `capture_process_scenario` | Command/args, environment, input schedule, PTY or pipes, deadlines and selected observation paths. | Terminal/output journal, interactions, lifecycle and selected effects. | Bound terminal cells/output; distinguish capture coverage from host isolation. |
| `compare_process_captures` | Compatible scenarios, declared normalization and optional event-order specification. | Differences across terminal, actions, process/file effects and instrumented network/shim events. | Partial order must be specified; timestamps or missing journals do not prove concurrency/equivalence. |
| `compare_artifacts`, `compare_functions` | Complete member inventories or matched function dossiers. | Byte/metadata/structure changes or code, references, strings and CFG differences. | Retain original identity and ambiguous matches; engine-incompatible facets remain incomparable. |
| `compare_bundles` | Two validated evidence bundles and explicit record pairing where needed. | Record membership, observation and revision-history differences. | An omitted record does not imply the behavior was absent. |
| `find_changed_behavior`, `correlate_static_and_runtime` | Validated comparisons and explicit hypotheses relating static and runtime dimensions. | Supported changes, correlations, candidates and unresolved causal questions. | Cochange alone does not establish causality; check build/environment compatibility. |
| `verify_reconstruction` | Finite structural/behavioral claims, original evidence and reconstructed target results. | Pass/fail/unknown per claim with authority and coverage. | All required comparable checks must pass; no claim of global equivalence. |
| `build_reconstruction_obligation_ledger`, `evaluate_reconstruction_coverage` | Reviewed claims, inventories, ownership/dependencies, cases and verifier results for a named boundary. | Obligation ledger or boundary coverage with missing, contradictory and stale proof. | Unique ownership, case completeness, required dependencies and verifier authority govern closure. |

## Sessions, annotations, and evidence records

Methods: [Sessions and evidence records](evidence-and-runtime.md) and [navigation and annotations](native-and-artifacts.md).

| Operation | Input and method | Result | Check or limit |
| --- | --- | --- | --- |
| `open_binary`, `close_binary`, `binary_session` | Target identity, selected engine/profile and optional compatible saved analysis. | Opened target, close/save outcome, or current capability/session state. | Serialize lifecycle with active work; failed save preserves usable state; engine changes are explicit. |
| `export_evidence_bundle`, `import_evidence_bundle`, `get_evidence_bundle` | Selected records, schema and canonicalization; path/overwrite policy for persisted bundles. | Validated portable bundle, imported records, or retained record snapshot. | Stage then publish/merge atomically; verify identity collisions, digests and import limits. |
| `list_unknowns`, `record_unknown`, `update_unknown`, `verify_unknown_resolution` | Question/evidence IDs, status filters or revision-checked change with resolution evidence. | Unknown heads, immutable revisions and a checked resolution outcome. | Reject stale writers; withdrawn/out-of-scope differs from evidentially resolved. |
| `get_navigation_context`, `inspect_address_context` | Selected GUI session or exact address and artifact. | Document/address/function context plus names, comment channels and bookmarks. | Sequential observations are not an atomic snapshot; unsupported facets stay unavailable. |
| `inspect_analysis_view` | Completed result ID, facet/item selector, offset and bounded limit. | Deterministic page/summary with parent identity, view digest and coverage. | No analysis rerun; stable IDs resolve ambiguous paths and page omissions do not prove absence. |

## Selection and verification

The [capability matrix](capability-index.md) starts from the question; this catalogue identifies the primitives behind the selected result. [Toolkit assembly](assembly-patterns.md) describes composition. The [firmware methods](firmware.md) also cover boot reconstruction, MCU/RTOS analysis, UEFI, delta updates, and logical partitions beyond basic scanning and extraction.

Catalogue membership establishes documented scope. Executable availability, platform support, and equivalent behavior require validation of the chosen implementation against representative inputs and relevant failure cases.
