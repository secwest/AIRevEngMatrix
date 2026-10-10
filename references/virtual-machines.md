# Specialized bytecode, AOT runtimes, and custom VMs

The [language taxonomy](language-decompilation.md) selects decompilers by representation. This guide covers bytecode and AOT cases needing additional version or runtime handling. Template: [VM study](../assets/templates/virtual-machine-study.yaml).

## Common procedure

Identify the container, VM family, bytecode/snapshot version, architecture if applicable, and compression/encryption layers. Retain member digests and byte coordinates. A VM name alone is not enough: opcode assignments, constant encodings, instruction widths, and serialized layouts can change independently of a product version.

Inventory functions/prototypes, constants, strings, imports, exports, exception regions, debug chunks, native boundaries and entry points. Select a version-compatible decoder before decompilation. Preserve unknown opcodes and raw operands rather than silently applying a nearby version's meanings. Names can be absent or obfuscated without making instruction evidence disappear.

Compare decisive decompiled branches, stack/register effects, and exception paths to bytecode. Runtime validation uses a bounded environment and known entry/input; loading a package or asking an interpreter to introspect it may execute initialization. Source reconstruction is distinct from extracting existing abstract syntax/debug information.

## Python and packaged Python

[pycdc](https://github.com/zrax/pycdc), [uncompyle6](https://github.com/rocky/python-uncompyle6), and [decompyle3](https://github.com/rocky/python-decompile3) are source-reconstruction candidates only for bytecode versions and constructs they actually support. xdis supplies a separate disassembly path. Record the tool's execution Python version separately from the target bytecode version. decompyle3's stated target range is narrower than current Python releases.

Extract supported packaged formats with an identified extractor and validate module headers before decoding. Keep native extensions, embedded interpreter identity, encrypted members, and missing modules separate. Check exception tables, closures, generators, comprehensions, and version-specific call instructions. A decompiler returning text without an error is not a correctness check. [Python intake](formats-and-runtimes.md) retains code-object identities and version rules.

## Lua, LuaJIT, and Luau

For standard Lua chunks, select [unluac](https://sourceforge.net/projects/unluac/) or [LuaDec](https://github.com/viruscamp/luadec) by exact chunk format and supported features. Record integer/number representation, endianness where format-dependent, stripped debug data, upvalues and nested prototypes. Check register effects, closure captures, varargs, and control-flow joins.

[LuaJIT](https://luajit.org/running.html) and [Luau](https://github.com/luau-lang/luau) use their own instruction sets and formats. Use matching VM tooling or a decoder derived from that exact implementation. A standard Lua header guess cannot justify decoding either. Record bytecode-to-native/JIT transitions separately. Recompilation checks use matching semantics and compare selected behavior; byte identity may differ with debug data or compiler choices.

## Dart and Flutter

Identify whether the shipped artifact is source/kernel data, a JIT snapshot, or native AOT code. Match the Flutter/Dart engine and snapshot metadata; platform and architecture matter. [Blutter](https://github.com/worawit/blutter) supports selected Flutter AOT analysis and produces metadata/annotated analysis artifacts. Check its current supported target and version detection before use.

Pair code and data snapshots from the same build. Recover class/function/object-pool references where supported, map them to native addresses, and verify representative call and allocation sites. Platform channels and FFI join Dart-side logic to native services. Tree shaking, obfuscation, inlining and stripped metadata limit original-source recovery. Deliver metadata and native pseudocode with the remaining gaps rather than labeling an object dump as original Dart.

## Unity Mono and IL2CPP

Distinguish managed assemblies from IL2CPP native output. Mono follows the CIL/ILSpy path. For IL2CPP, bind the native image and metadata from the same build before using [Cpp2IL](https://github.com/SamboyCoding/Cpp2IL) or [Il2CppDumper](https://github.com/Perfare/Il2CppDumper). Record metadata schema/version, registration tables, generic sharing, method mappings and tool diagnostics.

Check recovered method addresses in native instructions. Generated dummy assemblies may supply types/signatures without executable original bodies. Cpp2IL reconstruction is capability/version-dependent. Join serialized asset/script IDs to exact types only when the package evidence supports that relationship; asset extraction and code decompilation are separate results.

## Hermes, other JavaScript VMs, and snapshots

For React Native, identify whether the bundle is text or Hermes HBC. [hermes-dec](https://github.com/P1sec/hermes-dec) provides parsing, disassembly and partial pseudocode for supported versions. Preserve function indices, strings, exception records and byte offsets. Upstream documents limitations in its high-level control-flow output; apparent JavaScript text need not be runnable.

For QuickJS, V8 code caches or another embedded engine, bind the VM revision and serialization format. A cache can depend on flags, build configuration or surrounding source. Source maps or cached strings may help, but a cache is not automatically a portable source archive. Trace native bridge calls and captured code mappings only within the observed runtime scope.

## BEAM and interpreter-specific forms

For Erlang/Elixir, [beam_lib](https://www.erlang.org/doc/apps/stdlib/beam_lib.html) exposes BEAM chunks and available debug/abstract forms. Preserve imports, exports, atoms, literals and code-version identity. Abstract forms may be stripped or require a specific debug backend. A backend invocation can execute code; decode ordinary metadata without loading the target module where possible. OTP-version-matched disassembly is a separate fallback, and reconstructed Erlang does not establish original Elixir syntax.

Ruby YARV, PHP opcode caches, R bytecode, Lisp images and other interpreter-specific forms require their own exact runtime and container match. Use native/runtime disassembly interfaces when available and record initialization effects. If no compatible offline decoder exists, preserve the bytes, explain the known header/runtime facts, and mark the undecoded body explicitly. Do not manufacture source-like output from string tables.

For ActionScript/SWF, [JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler) can expose supported AVM1/AVM2 code and resources. Retain SWF/ABC identities, method/constant-pool indices, event linkage and extraction boundaries; verification follows the same instruction-to-output checks.

## JIT and language-runtime specializations

Distinguish source, serialized runtime objects, bytecode and generated native code before selecting an interface. Julia's [reflection interfaces](https://docs.julialang.org/en/v1.9/devdocs/reflection/) expose lowered, type-inferred, LLVM and native views for selected methods. Match the installed API and preserve the method plus argument-type signature; one specialization does not represent every call. Loading definitions, expanding macros or requesting generated code can run initialization or compilation logic. Keep these operations in the runtime workflow.

Bind captured native code to its runtime version, compilation settings, method identity and lifetime. A later compilation or invalidation can replace the code at an address. Record mappings and generated bytes from the same observation window. Verify decisive behavior using the selected specialization and concrete inputs; IR output alone does not reconstruct the original program.

Haskell, OCaml, Lisp and other compiled runtimes need exact compiler conventions for closures, tagged values, garbage-collector roots, exceptions and foreign calls. Lazy evaluation and runtime thunks may move work away from the apparent source call. COBOL analysis also binds record encoding, numeric representation and calling convention to the actual compiler/platform. Apply native instruction checks or the matching VM route to the shipped representation; preserve unavailable source abstractions explicitly.

## Custom VM recovery

The interpreter and its bytecode are separate artifacts. Identify dispatch, instruction fetch, virtual PC, virtual stack/registers, constants, calls, exception behavior and external operations. Recover a bounded opcode subset using interpreter code and controlled traces. Define each decoded operation's width, operands, state effects and next-PC rule.

Implement a decoder or lifter only for the recovered subset. Unknown opcodes stop or yield explicit undecoded regions. Differentially check small bytecode fixtures against the real interpreter or a trusted trace, including branches, boundary values, malformed operands and exceptions. A dispatch table label alone does not establish semantics.

**Deliverable:** versioned bytecode specification, decoder/decompiler output with coordinates, checked VM/native transitions, fixtures, and unresolved operations. This method also applies to supported legacy p-code and proprietary controller formats, with vendor-specific parsing and acquisition requirements.
