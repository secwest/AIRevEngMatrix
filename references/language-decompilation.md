# Decompilation by language and representation

A source language, the shipped representation, and the decompiler's output language are three different properties. Rust can ship as native code or WebAssembly; C# can ship as CIL or native AOT; JavaScript can ship as text or VM bytecode. Select the engine from the actual bytes, then add language metadata and runtime interpretation.

Template: [decompilation study](../assets/templates/decompilation-study.yaml). The [coverage map](coverage-map.md) connects these language families to other analysis methods.

The [development-environment workflows](development-environments.md) provide detailed intake, tool selection, language-construct analysis and assessment for each major ecosystem. Use the relevant workflow with the [source fixtures and build profiles](environment-fixtures.md); a taxonomy row is only the starting selection.

## Native engines

| Engine | Output and use | Selection notes |
| --- | --- | --- |
| [Ghidra](https://github.com/NationalSecurityAgency/ghidra) | Native instructions, data types, references, p-code, and decompiler output | Check processor/compiler specifications and the actual decompiler result. Rust, C++, Swift, or another source language still needs language-aware interpretation. |
| [IDA and Hex-Rays](https://docs.hex-rays.com/getting-started/basic-usage) | Native analysis and licensed architecture-specific decompilers | Disassembler support and decompiler support differ. Record the installed decompiler, edition, plugins, and automation interface. |
| [Binary Ninja](https://binary.ninja/) | LLIL/MLIL/HLIL, types, references, and high-level presentations | Check architecture lifting, analysis completion, and edition/API support. Its [Pseudo Rust presentation](https://binary.ninja/2024/11/20/4.2-frogstar.html) changes output syntax; it does not establish original Rust types or ownership. |
| [angr decompiler](https://docs.angr.io/en/latest/) | Scriptable CFG/IR analysis and pseudocode; Rust-specific analysis where available | Keep loader assumptions and unsupported execution/lifting visible. The installed release or revision determines availability of newer analyses. |
| [Rizin with rz-ghidra](https://github.com/rizinorg/rz-ghidra) | Ghidra-based decompilation through Rizin | Rizin navigation and rz-ghidra decompilation are separate capabilities; match plugin/core versions. |
| [radare2 with r2ghidra](https://github.com/radareorg/r2ghidra) | Native analysis and Ghidra-based decompilation through radare2/r2pipe | Keep radare2 and plugin versions compatible. r2ghidra and rz-ghidra belong to different host frameworks. |
| [RetDec](https://github.com/avast/retdec) | LLVM-based machine-code decompilation and structural analysis | Upstream reports limited maintenance. Check exact architecture/format support and representative outputs before selecting it. |
| Hopper and JEB | Native analysis through their supported processor and automation interfaces | Use the installed product's documented feature set; a shared product name does not imply every decompiler or architecture is licensed. |

## Language taxonomy

| Source family or shipped runtime | Decompiler or primary engine | Supporting tools or metadata | Recoverable result and boundary |
| --- | --- | --- | --- |
| **Rust native** | **Oxidizer/angr**, Ghidra, Hex-Rays, Binary Ninja | rustc-demangle/rustfilt, Rust symbols, DWARF/PDB, library signatures | Rust-specific or native pseudocode, type/dispatch candidates; compiler version, optimization and ABI affect recovery. [Rust guide](rust-reverse-engineering.md). |
| C | Native engines above | Imports, debug info, ABI, known library signatures | Functions and data-flow interpretation; original names/macros may be absent. |
| C++ | Native engines above | RTTI, vtables, exception/unwind metadata, demanglers | Class/dispatch candidates and native pseudocode; templates, inlining and multiple inheritance require ABI checks. |
| Zig, D, Nim | Native engines above | Compiler/runtime signatures and surviving debug info | Native behavior and language-related hypotheses. Syntax resembling C does not identify the original language. |
| Haskell, OCaml, native Lisp and COBOL | Compatible native engine; exact VM decoder for bytecode variants | Closure/heap metadata, runtime entry points, tagged values, compiler ABI, record encodings | Native/VM behavior and surviving structure; a universal original-language decompiler is not assumed. |
| Julia and other JIT specializations | Matching runtime introspection plus native/IR analysis | Method/type specialization, runtime revision, generated code mapping | Selected lowered/typed IR or machine code; runtime inspection can trigger initialization or code generation. [JIT method](virtual-machines.md). |
| Fortran, Ada, Pascal/Delphi native | Native engines above; [IDR](https://github.com/crypto2011/IDR) for compatible Delphi targets | Array descriptors, runtime calls, RTTI, form resources, compiler-specific conventions | Native behavior, data/resource relationships; compiler and target support must be demonstrated. |
| Swift and Objective-C | Native engines, Hopper, JEB where supported | Swift demangling/reflection metadata, Objective-C runtime records | Types, selectors, witness/dispatch candidates and native code. [Native methods](native-and-artifacts.md). |
| Go | Native engines above | GoReSym, runtime metadata and ABI | Located functions/types and native behavior; GoReSym is a metadata recovery tool. [Go method](formats-and-runtimes.md). |
| C#, F#, VB.NET, other CLR languages | ILSpy; [dnSpyEx](https://github.com/dnSpyEx/dnSpy) when interactive debugging is needed | CIL, metadata tokens, exception tables, PDBs | Managed reconstruction, often C#-shaped; source-language constructs and Native AOT require separate handling. [Managed method](managed-mobile-firmware.md). |
| Java, Kotlin, Scala and other JVM languages | Vineflower, [CFR](https://www.benf.org/other/cfr/) | Class descriptors, bootstrap methods, language metadata, dependencies | Usually Java-shaped reconstruction. Coroutines, lambdas and synthetic methods need bytecode checks. [JVM method](formats-and-runtimes.md). |
| Android DEX/smali | JADX, JEB; Apktool for package/resources/smali | Manifest/resources, exact DEX descriptors, native libraries | Java-like code and package relationships; resource decoding is distinct from decompilation. |
| Python bytecode | [PyLingual](https://github.com/syssec-utd/pylingual), [pycdc](https://github.com/zrax/pycdc), [uncompyle6](https://github.com/rocky/python-uncompyle6), [decompyle3](https://github.com/rocky/python-decompile3), for supported versions | xdis, bytecode magic, code objects and package extraction | Source candidates or disassembly; exact release/opcode/model support requires a probe. [Python workflow](python-reverse-engineering.md). |
| Lua | [unluac](https://sourceforge.net/projects/unluac/), [LuaDec](https://github.com/viruscamp/luadec) | Exact Lua chunk version, numeric representation and debug data | Lua reconstruction for compatible chunks. LuaDec labels its 5.2/5.3 support experimental. |
| LuaJIT and Luau | Matching VM tools; LJD or Unluau where compatible | VM revision, opcodes, constants, upvalues and native/JIT boundary | Experimental source recovery or disassembly; [interpreter workflow](interpreter-reverse-engineering.md) records maturity and checks. |
| Dart / Flutter | Native engine plus [Blutter](https://github.com/worawit/blutter) for supported AOT targets | Matched Dart/Flutter snapshot and object metadata | Annotated native code, objects and call candidates; Blutter is not a general original-Dart-source recovery guarantee. |
| Unity Mono | ILSpy/dnSpyEx plus asset inspection | Managed assemblies and serialized asset/script IDs | Managed logic and asset links. |
| Unity IL2CPP | [Cpp2IL](https://github.com/SamboyCoding/Cpp2IL), [Il2CppDumper](https://github.com/Perfare/Il2CppDumper), native engine | Matching native binary and metadata pair | Recovered managed structure and supported reconstruction; dummy assemblies can contain no original method bodies. |
| Unreal Blueprint and Godot GDScript | KismetKompiler, GDRE Tools for supported versions | Engine/package metadata, script bytecode, resource/object identities | Supported script reconstruction; native/managed modules follow their own routes. [Game environments](mobile-game-reverse-engineering.md). |
| JavaScript/TypeScript text | AST tools, source maps, formatters | Original-source availability, generated locations and bundler structure | Shipped/recovered text and inferred structure. Types erased during compilation are not recovered by formatting. |
| React Native Hermes | [hermes-dec](https://github.com/P1sec/hermes-dec) | Exact HBC version, function/string tables and native bridge | Disassembly and partial pseudocode; upstream cautions that output is not generally valid JavaScript. |
| Other JS bytecode, JIT snapshots, QuickJS/V8 internals | View8 for supported serialized V8 code; matching VM revision and native/runtime tools | Snapshot format, code cache, runtime tables and captured mappings | Bounded reconstruction or observations; [JavaScript workflow](javascript-reverse-engineering.md) binds the exact representation. |
| Erlang and Elixir BEAM | OTP [beam_lib](https://www.erlang.org/doc/apps/stdlib/beam_lib.html), version-matched disassembly/debug-info tools | Chunks, exports/imports, abstract/debug forms when present | Bytecode and metadata; stripped abstract forms and original Elixir syntax may be unavailable. |
| Ruby YARV / PHP opcodes | Matching runtime disassembly/compiler inspection | Exact interpreter version and serialization format | Version-specific instructions or reconstructed behavior. Runtime inspection can execute initialization and needs a bounded environment. |
| ActionScript / Flash SWF | [JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler) | AVM1/AVM2 identity, ABC tables and resource links | ActionScript reconstruction and resource extraction for supported inputs. |
| WebAssembly from any language | wasm-tools, [WABT](https://github.com/WebAssembly/wabt), including wasm-decompile | Module/component features, names, imports and host ABI | WAT or C-like reconstruction; output syntax does not identify the source language. |
| EVM / Solidity / Vyper | EVM decoder and a compatible analysis engine | Fork rules, runtime versus creation code, proxy/storage context | Interface/behavior candidates; source-language recovery and full ABI inference remain conditional. |
| GPU, eBPF, shader IR | Architecture/IR-specific decoders | Kernel/driver target, bindings, maps and runtime environment | Instruction or intermediate representation with checked host boundaries. [Platform methods](platform-and-kernel.md). |
| Legacy VB p-code, proprietary VM or PLC bytecode | Version-specific vendor tooling or an explicitly recovered decoder | Container, dispatch loop, opcode semantics and runtime state | Supported subset and gaps. A native engine can inspect the interpreter without decoding its bytecode. [VM method](virtual-machines.md). |

## Decompilation procedure

1. Identify the representation and runtime/compiler evidence. Separate declared metadata from inferred language fingerprints. A package can contain several languages and execution formats.
2. Select a compatible decompiler and its supporting parsers. Record revision, architecture, bytecode version, license/API, plugins, and symbol provenance. For an experimental engine, first use a small known fixture with the relevant constructs.
3. Preserve raw disassembly, IR, metadata, diagnostics, and code-to-output mappings. Bind function identity using image/address, method descriptor/token, or VM function index as appropriate.
4. Check function boundaries, calling conventions, argument/return locations, exceptions, indirect dispatch, integer widths, and memory accesses. Debug information must match the binary; plausible names from another build can mislead analysis.
5. Classify the output as recovered original text, compiler/debug metadata, decompiler pseudocode, translated presentation, or analyst reconstruction. Each class has different evidentiary weight.
6. Compare decisive control/data flow to bytes and, where relevant, concrete execution. Agreement between two decompilers is useful corroboration but can share the same mistaken assumptions.

Recompilation is an optional check requiring compatible dependencies and semantics. Byte equality is usually too strong across compilers; passing a finite set of tests establishes only those cases. Document missing constructs, irreducible control flow, stripped metadata, and unmodeled runtime dependencies.

## Native language details

C++ reconstruction retains object adjustments, thunks, constructors/destructors, virtual bases, exception cleanup, and RTTI identity. A vtable-shaped region needs call-site evidence. Zig/D/Nim/Fortran/Ada routes use native ABI and metadata checks without inventing a dedicated source decompiler. Delphi resource and class recovery must distinguish recovered structure from method-body decompilation.

Managed languages require source-language interpretation after bytecode recovery: async/coroutine state machines, closures, generated bridges, pattern matching, and dynamic call sites can survive as lowered forms. A Java-shaped view of Kotlin or C#-shaped view of F# does not restore every source abstraction. [VM workflows](virtual-machines.md) cover specialized bytecode and AOT cases.
