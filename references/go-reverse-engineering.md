# Go development environments

Scope: Go native executables/libraries, stripped builds, cgo and compiler/runtime metadata. Record the target Go toolchain independently from the toolchain used to run an analyzer. Records: [environment study](../assets/templates/environment-study.yaml) and [decompilation study](../assets/templates/decompilation-study.yaml).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| [GoReSym](https://github.com/mandiant/GoReSym) | Recover supported function, type and source metadata | Check runtime layout/version support and original address mappings. |
| [Redress](https://github.com/goretk/redress) / [GoRE](https://github.com/goretk/gore) | Inspect stripped Go structure, package/type records and estimated source organization | Estimated source structure is not recovered function-body source. Keep uncertain matches labeled. |
| Ghidra, Hex-Rays, Binary Ninja and other compatible native engines | Native pseudocode and instruction/reference analysis | Match Go calling conventions and runtime helpers before interpreting arguments or returns. |
| Go toolchain binary inspection, matching DWARF/build information | Independent build/symbol checks | A tool that parses build information may still lack support for that binary's native or runtime structures. |

## Bounded recovery procedure

1. Identify format, architecture, Go build/runtime evidence, entry/startup, build mode and retained metadata. Separate standard Go, TinyGo and other implementations; compatible source syntax does not imply compatible runtime layout.
2. Recover available function boundaries, package/type names and line tables. Translate file/image/load coordinates and confirm representative boundaries in instructions before importing annotations.
3. Separate runtime and library candidates from the requested application path while retaining allocation, stack-growth, panic and synchronization behavior that affects it.
4. Correct the native ABI using call sites, wrappers and available metadata. Register assignment, aggregate returns, stack growth and cross-language wrappers are version/target-sensitive.
5. Explain one feature through application functions and runtime operations. Use concrete execution only when the finding depends on scheduling, reflection, callbacks or external state.

## Constructs and checks

| Construct | Required check |
| --- | --- |
| Strings and slices | Verify pointer/length/capacity roles, bounds and backing data; descriptor-like words need context |
| Interfaces | Resolve type/interface metadata, data pointer, method dispatch and nil cases; typed nil differs from an absent interface |
| Maps | Identify runtime implementation and operations; avoid imposing an older map layout on a new compiler |
| Goroutines/channels | Track launch, send/receive/select and scheduler boundaries; static calls do not establish actual event order |
| Defer/panic/recover | Follow normal and exceptional cleanup, compiler lowering and the context where recovery occurs |
| Generics/closures/cgo | Preserve dictionaries/specializations and captured state where present; cgo crossings need the actual foreign ABI |

Stripping, obfuscation and compiler changes can remove or alter identifying data. A failed metadata parse is not proof that a file is not Go. Native instructions remain a narrower fallback when the runtime-specific helper cannot decode the target.

## Representative assessment

The [Go fixture](../assets/fixtures/environment-patterns.go) includes interface dispatch, a closure and a deferred cleanup. [Profiles](environment-fixtures.md) compare a debug-oriented build with a stripped optimized build. Verify the error cases and cleanup behavior without requiring fixed function names or boundaries.

For concurrent targets, add channel synchronization, a typed-nil interface and a panic/recover case with an explicit event oracle. Repeat relevant schedules; record a successful observed schedule separately from any claim about all schedules.

**Deliverable:** recovered metadata, checked native interpretation, ABI/runtime assumptions and original locations. A package tree, guessed source line range or demangled name is supporting data, not a recovered Go project.
