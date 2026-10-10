# Scientific, functional, legacy, and contract environments

These routes provide the same intake, tool selection, construct analysis and result checks as the main language workflows. Some environments supply introspection or metadata recovery instead of a mature source decompiler. Record that output kind in the [environment study](../assets/templates/environment-study.yaml).

## Scientific and numerical environments

| Environment | Candidate route | Decisive checks |
| --- | --- | --- |
| Julia | [Runtime reflection](https://docs.julialang.org/en/v1.9/devdocs/reflection/), typed/lowered IR, LLVM and native views | Bind method/type specialization, runtime/world context and generated-code lifetime; loading/compiling definitions can execute code. |
| R | Matching [`compiler` disassembly](https://stat.ethz.ch/R-manual/R-devel/library/compiler/html/compile.html), function/body inspection and native analysis | Bind serialized object/runtime version, closure environment, promises and native package boundaries. Loading an object is a runtime operation with format-specific constraints. |
| Fortran | Native decompiler, DWARF and compiler/runtime ABI information | Check array descriptors, shape/strides, column-major indexing, hidden lengths, complex returns and numerical compiler options. |
| MATLAB/Octave deployments | Available source and matching vendor/runtime inspection; native route for generated native code | Identify source, P-code/serialized form, runtime archive or generated executable. Require an actual compatible decoder before claiming protected source recovery. |

Workflow: identify the shipped representation and compiler/runtime dependencies; bind the selected function and data shapes; recover available IR or native code; trace numerical and foreign-library calls; validate selected inputs under matching precision, layout and execution settings. Fused operations, fast-math, NaNs, signed zero and parallel reductions can defeat a naive source-level equivalence claim.

Representative cases include a strided array/view, a closure environment, a foreign call, an exceptional value and a boundary-size input. Compare numeric outputs under an explicit tolerance and exact error/shape behavior. A JIT specialization covers only its recorded argument types and runtime context.

## Functional and legacy compiled environments

| Environment | Candidate route | Recovery boundary |
| --- | --- | --- |
| Haskell/GHC | Native engine plus matching runtime/debug/interface information | Lazy thunks, closure/info tables, allocation and garbage-collector conventions need compiler-specific interpretation; an interface file is not a complete method-body decompiler. |
| OCaml | Matching bytecode/object inspection or native engine | Bind compiler version and bytecode versus native form; tagged values, closures, exceptions and C stubs need separate checks. |
| Lisp/Scheme images | Matching implementation's disassembly/introspection and native engine | Image loading may initialize code; macros and original source may be absent even when compiled functions are inspectable. |
| Delphi/Pascal | Native engine and [IDR](https://github.com/crypto2011/IDR) on its supported targets | Pair RTTI/form resources with constructors and events; compiler/bitness support is explicit. |
| VB6/legacy p-code | Compatible format-specific decoder or recovered interpreter semantics | First distinguish native code from p-code; do not apply the CLR/VB.NET route by language name. |
| COBOL | Native/VM engine and exact compiler/runtime record metadata | Preserve encoding, packed decimal/sign handling, record layout, calling conventions and I/O status behavior. |

Workflow: identify compiler/runtime and native/bytecode/image form; recover only supported metadata; establish closure/record/call representations from code; follow exception/GC/foreign boundaries; validate a bounded feature. The [custom VM method](virtual-machines.md) applies when no compatible decoder exists.

Representative cases cover an allocated closure, a tagged or packed value, a failure path and a foreign/record boundary. For Delphi, add an actual resource event; for COBOL, include negative/decimal fields and a record-length mismatch. Keep fixture specifications distinct from completed runs.

## Smart-contract development environments

[Heimdall-rs](https://github.com/Jon-Becker/heimdall-rs) is a candidate for supported EVM disassembly/decompilation and interface inference. Pair it with a fork-compatible instruction reader and a local execution fixture when behavior matters. Selectors and signature databases can suggest names without uniquely establishing a full ABI or source.

1. Bind chain-independent bytecode identity and creation versus runtime form. For a chain observation, record chain, block and relevant account/state identities.
2. Identify compiler metadata where retained, fork rules, dispatch, revert/return paths, events and storage accesses. Separate proxy code from implementation and preserve delegate-call storage context.
3. Compare high-level output to stack/memory/storage instructions. Solidity, Vyper and Yul can generate similar code; syntax is not proof of origin.
4. Validate selected calls in a local matched state with explicit caller, value, calldata and block conditions. An RPC observation is not a complete proof of every state-dependent path.

Representative cases include a dynamic ABI argument, revert, event, packed storage field and proxy/delegate boundary. Other execution formats, including non-EVM contract VMs, require their own decoder, verifier/runtime rules and fixtures; EVM tools do not supply that support.

**Deliverable:** available IR/pseudocode/metadata, representation-qualified behavior, checked data/runtime contracts and the exact unsupported source-recovery scope.
