# Swift, Objective-C, and Xcode environments

Scope: Mach-O applications/frameworks, Swift and Objective-C runtime metadata, mixed C/C++, and Embedded Swift where applicable. Records: [environment study](../assets/templates/environment-study.yaml), [decompilation study](../assets/templates/decompilation-study.yaml). Bundle/signing work follows [native artifacts](native-and-artifacts.md).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| Ghidra, Hex-Rays, Binary Ninja, Hopper, JEB | Supported native decompilation and reference analysis | Match architecture, ABI and installed product support. Readable pseudocode does not recover every Swift abstraction. |
| [DSDump](https://github.com/DerekSelander/dsdump) | Symbols and supported Objective-C/Swift type metadata | Recovered declarations are metadata views; check parser support and code associations. |
| `swift-demangle`, LLVM/Mach-O tools, matching dSYM | Symbol interpretation, load structure and debug mappings | Preserve mangled names and UUID/slice identity. Source paths do not establish source availability. |
| LLDB and platform runtime inspection | Concrete selector, dispatch, object and task observations | Expression evaluation and runtime attachment are separate from offline metadata decoding. |

## Intake and recovery

1. Inventory executable slices, nested frameworks/extensions, resources and signatures. Bind Mach-O UUID, CPU subtype, deployment target and matching dSYM. A universal binary contains distinct code slices.
2. Map sections, load commands, relocations/fixups, imports and available code bytes. Treat encrypted or absent code as an acquisition gap; metadata strings are not a substitute for readable function bodies.
3. Recover Objective-C classes, categories, protocols, methods and selector references. A selector can have several implementations. Trace receiver-class evidence, registration and the actual dispatch site before assigning a target.
4. Recover Swift symbols and supported descriptors, relative pointers, generic requirements and protocol conformances. Check decoded records against file/load coordinates before using them to rename or type functions.
5. Decompile the selected native path with its actual convention. Follow Swift/Objective-C/C bridges, argument ownership, aggregate returns and error results. Preserve unresolved dynamic dispatch.

## Language-specific checks

| Construct | Analysis requirement |
| --- | --- |
| Swift generics/protocols | Track type metadata and witness arguments, concrete specialization and existential containers; verify call-site layouts |
| Swift enums/optionals | Recover payload/tag tests and spare-bit/niche use from the target; source-level case names may be absent |
| Swift async/actors | Identify resume functions, task/context state and isolation hops; a static continuation does not establish observed scheduling |
| ARC and closures | Trace retains/releases, captured environment and block/closure invocation; optimization can coalesce ownership operations |
| Objective-C dynamics | Categories, forwarding, swizzling and KVC/KVO can change dispatch; static method lists provide candidates |
| arm64e and mixed code | Preserve pointer-authentication/fixup interpretation and ABI boundaries; do not treat encoded pointers as ordinary addresses |

Apple-platform Swift ABI stability has a defined scope; it is not a guarantee about every Swift target or metadata parser. [Embedded Swift has distinct ABI constraints](https://docs.swift.org/latest/documentation/embeddedswift/abi/) and can emit different or reduced metadata. Bind compiler mode before importing full-Swift layouts.

## Representative assessment

The [Swift fixture](../assets/fixtures/environment-patterns.swift) exercises a protocol existential, generic wrapper, optional parsing and thrown error. [Profiles](environment-fixtures.md) cover unoptimized and optimized builds. Compiler optimization may specialize away dispatch; check the emitted result.

For an Apple UI feature, add a tiny Objective-C selector/block callback and a Swift-to-Objective-C crossing on the actual platform. For concurrency, add one suspension/resumption and cancellation path. Retain the app, selected slice, dSYM and runtime version together.

**Deliverable:** native behavior, checked type/selector/witness hypotheses, code and metadata coordinates, resource links and unresolved dynamic/runtime effects. Declaration dumps and pseudocode have different evidentiary roles.
