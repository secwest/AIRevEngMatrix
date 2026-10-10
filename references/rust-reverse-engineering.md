# Rust reverse engineering

Rust native binaries need a compatible machine-code analyzer plus Rust-aware interpretation. Rust-specific decompilers can improve recovered abstractions, while debug information, demangling, library identification, and concrete tests provide independent checks.

Template: [decompilation study](../assets/templates/decompilation-study.yaml). Fixture: [Rust behavior example](../assets/fixtures/rust-patterns.rs) and [expected cases](../assets/fixtures/rust-patterns.yaml).

## Tools and their roles

| Tool | Role | Practical qualification |
| --- | --- | --- |
| [Oxidizer](https://github.com/sefcom/oxidizer) / Rust analysis in angr | Rust-specific pseudocode and recovery of selected high-level constructs from native binaries | Research-origin implementation. Upstream reports integration into angr's main branch; check the installed revision, supported inputs, compiler/type databases, and diagnostics. Main-branch availability does not imply every packaged release includes it. |
| [Binary Ninja Pseudo Rust](https://binary.ninja/2024/11/20/4.2-frogstar.html) | Rust-like presentation of decompiled native code, with access to underlying IL | Output-language selection is distinct from Rust-specific type and semantic recovery. Compare the IL and machine instructions at decisive points. |
| [IDA Rust plugin](https://docs.hex-rays.com/8.4/user-guide/plugins/plugins-shipped-with-ida/rust-plugin) with Hex-Rays | Rust-oriented analysis assistance around a native decompiler | Plugin functionality and demangler integration depend on the IDA version. Confirm the current installation rather than assuming an older manual's exact behavior. |
| Ghidra | Native decompilation with Rust-related identification, demangling/debug-info support as provided by the installed release | Check actual recovered names, strings, functions and types against the target. |
| [rustc-demangle](https://github.com/rust-lang/rustc-demangle), [rustfilt](https://github.com/luser/rustfilt) | Decode surviving Rust symbol names | Keep original and decoded symbols. These are naming tools, not decompilers or proof of a type's layout. |
| [GhidRust](https://github.com/DMaroo/GhidRust) | Historical Ghidra extension with function signatures and C-to-Rust presentation | Upstream says development is permanently paused and the remaining features are unreliable. Treat it as a legacy experiment, with an exact version and fixture, rather than a default dependency. |

Tool status is based on upstream documentation checked on 2026-10-10; compatibility is established per installation and target. Oxidizer's published approach includes type inference and recovery of selected enum/control-flow patterns. Its [upstream implementation](https://github.com/sefcom/oxidizer) describes the available pipeline and version-dependent data. A recovered construct remains an interpretation to verify.

## Intake and compiler evidence

Record format, architecture, ABI, image base, sections, imports, symbols, debug information, and build identifiers. Rust runtime/panic paths, mangled names, and library patterns are evidence for a Rust origin; their absence in a stripped or heavily optimized file does not exclude it. A compiler version inferred from a library match retains the matching confidence and database identity.

Record panic strategy, optimization, LTO, and target features when known. A function may be inlined, merged, monomorphized into several implementations, or removed. An inferred crate/module path is not a recovered source repository. Rust compiler internals and the [Rust type-layout rules](https://doc.rust-lang.org/reference/type-layout.html) constrain which layout assumptions are valid.

## Recover names and code boundaries

Demangle available symbols without dropping their original spelling, hash suffixes, or address association. Bind symbols and debug data to the correct binary/build. Distinguish Rust ABI, declared foreign ABI, and compiler-generated wrappers. A decompiler's C-style signature can hide multiple register returns, indirect return storage, or aggregate arguments.

Classify known library and allocator functions using matched signatures plus call-site evidence. Keep the database's architecture/compiler assumptions. Removing library noise from a view must not erase cleanup, allocation, bounds checks, or panic paths that affect the question.

## Interpret Rust constructs

| Construct | Analysis questions and checks |
| --- | --- |
| Slices and strings | Trace pointer and length together and inspect actual memory accesses. Validate encoding separately. Do not assume every pointer/length pair is a Rust slice. |
| Trait objects | Establish data and dispatch metadata from construction and call sites. Resolve methods with receiver/argument evidence. Vtable layouts and method ordering require target/compiler evidence. |
| Enums, Option and Result | Recover discriminant tests, payload access and return conventions. Niche encodings may replace an explicit tag. A zero/nonzero test alone does not identify Option. |
| Ownership and drop paths | Track allocation, moves as reflected in machine state, cleanup and deallocation. Borrow-checker lifetimes are compile-time information and are not generally recoverable from stripped bytes. |
| Generics and closures | Separate concrete monomorphizations and closure environment captures. Similar code does not establish the original generic definition or trait bounds. |
| Async/await | Identify state storage, poll-style control flow, wake/context interactions and cleanup. Static state transitions need concrete input/scheduler conditions before a reachability claim. |
| Panic and error handling | Distinguish explicit Result propagation, bounds checks, assertions, unwind cleanup and abort paths. Pretty output may fold away details required for a correctness or failure question. |
| FFI and unsafe regions | Check the actual ABI, pointer provenance available in the trace, widths, allocation ownership and error conventions. Source-level `unsafe` boundaries need not survive in code. |

## Bounded decompilation workflow

1. Select the function or feature and record its exact identity. Obtain native instructions and one baseline decompiler result.
2. Choose a Rust-specific pass only where it can improve the requested result. Probe Oxidizer/angr on a representative fixture before a large run; record compiler/library database dependencies. Use a native fallback when unsupported.
3. Retain pre/post-analysis outputs and relevant simplifications. Check inferred enums, strings, trait calls and error returns against decisive instruction paths and available metadata.
4. Build a small concrete harness only if runtime proof matters. Use the actual calling convention and dependencies. Pure native tests, emulation and full process scenarios establish different scopes.
5. Deliver the behavior explanation, pseudocode with its authority, type/dispatch hypotheses, checked source locations and unresolved compiler/runtime assumptions.

For Rust in firmware, also bind memory layout, panic behavior, interrupt context, allocator availability, and hardware dependencies through [Firmware](firmware.md). For Rust compiled to Wasm, use [Wasm inspection](formats-and-runtimes.md) and preserve its host interface.

## Fixture use

The supplied dependency-free source includes Result/enum handling, a trait call, a generic wrapper, and borrowed text parsing. Build with an explicitly recorded Rust toolchain using both low optimization/debug information and optimized/stripped settings where supported. No fixed function address, register convention, or enum layout is assumed across builds.

The expected-case file defines observable output and exit status. First establish the behavior of each compiled artifact, then analyze it with the selected decompiler. Check whether the interpretation explains every fixture case and record which source constructs were actually recovered. Successful compilation and execution of this fixture do not certify a decompiler or arbitrary Rust targets.
