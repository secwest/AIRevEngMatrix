# Decompilation workflows by development environment

An environment consists of its compiler/runtime, shipped representation, libraries, metadata and packaging. An editor or IDE name alone cannot select a decompiler. These workflows give each major environment an intake route, candidate efforts, construct-specific analysis, representative assessment and deliverable.

## Workflow index

| Environment | Decompiler/recovery efforts | Detailed workflow |
| --- | --- | --- |
| C/C++ with MSVC, GCC, Clang or embedded compilers | Ghidra, Hex-Rays, Binary Ninja, r2ghidra/rz-ghidra, RetDec plus ABI/debug readers | [C/C++](cpp-reverse-engineering.md) |
| Rust | Oxidizer/angr, compatible native engines, Rust symbol/type helpers | [Rust](rust-reverse-engineering.md) |
| .NET/Visual Studio, Mono, C#/F#/VB.NET | ILSpy, dnSpyEx, dotPeek, metadata/CIL readers; native route for AOT | [.NET](dotnet-reverse-engineering.md) |
| JVM/IntelliJ/Eclipse, Java/Kotlin/Scala | Vineflower and its compatible language plugins, CFR, class-file tools | [JVM and Android](jvm-android-reverse-engineering.md) |
| Android Studio / DEX / JNI | JADX, JEB, Apktool and native engines | [JVM and Android](jvm-android-reverse-engineering.md) |
| Xcode, Swift and Objective-C | Native decompilers, DSDump, Swift demangler, Mach-O/dSYM tooling | [Apple](apple-reverse-engineering.md) |
| Go | GoReSym, GoRE/Redress, native decompiler | [Go](go-reverse-engineering.md) |
| CPython and packaged Python | PyLingual, pycdc, uncompyle6/decompyle3, xdis, pyinstxtractor-ng | [Python](python-reverse-engineering.md) |
| JavaScript/TypeScript, Node, Electron, React Native | AST/source-map recovery, Wakaru, hermes-dec, View8 and runtime capture | [JavaScript](javascript-reverse-engineering.md) |
| Dart/Flutter | Blutter within its target range and native analysis | [Flutter and games](mobile-game-reverse-engineering.md) |
| Unity Mono/IL2CPP | Managed engines, Cpp2IL, Il2CppDumper and native analysis | [Flutter and games](mobile-game-reverse-engineering.md) |
| Unreal and Godot | CUE4Parse/FModel, KismetKompiler, GDRE Tools, native/managed engines | [Flutter and games](mobile-game-reverse-engineering.md) |
| Lua, LuaJIT and Luau | unluac, LuaDec, LJD, Unluau, matching VM tools | [Interpreters](interpreter-reverse-engineering.md) |
| Erlang/Elixir | OTP debug/abstract-form recovery and BEAM disassembly | [Interpreters](interpreter-reverse-engineering.md) |
| Ruby/PHP | Matching ISeq/Zend opcode inspection, VLD and native/runtime analysis | [Interpreters](interpreter-reverse-engineering.md) |
| Wasm toolchains and component runtimes | WABT, wasm-tools and matching host/runtime analysis | [Wasm](wasm-reverse-engineering.md) |
| Julia, R, Fortran, MATLAB/Octave | Runtime IR/disassembly or native analysis according to representation | [Scientific and specialized](specialized-development-environments.md) |
| Haskell, OCaml, Lisp, Delphi, VB6 and COBOL | Compiler/runtime metadata, compatible native/VM engines, IDR where supported | [Scientific and specialized](specialized-development-environments.md) |
| Solidity/Vyper/Yul and EVM | Heimdall-rs, fork-compatible decoding and local execution checks | [Contracts](specialized-development-environments.md) |

Tool presence in this index means there is a documented selection route. The [language taxonomy](language-decompilation.md) distinguishes decompiler engines, metadata helpers, disassemblers and output languages. The relevant workflow describes target restrictions and experimental or partial recovery.

## Common assessment contract

- **Identify:** artifact digests, compiler/runtime evidence, architecture/ABI, optimization/publication mode and paired metadata/resources.
- **Select:** exact decompiler revision, supported input/version, CLI/API, plugins/models/databases and a narrower fallback.
- **Recover:** a named function/method/feature with raw instructions or IR and output-coordinate mappings; retain unsupported bodies and diagnostics.
- **Interpret:** language lowering, dispatch, errors/cleanup, concurrency and native/runtime crossings relevant to the question.
- **Check:** a representative baseline fixture, decisive instruction/IR checks and finite reconstructed behavior where runnable.
- **Deliver:** the supported explanation or source/pseudocode plus identities, reproducible checks and the remaining gap.

The [environment study](../assets/templates/environment-study.yaml) records these facts. [Fixture sources and build profiles](environment-fixtures.md) supply small inputs for ten additional environments alongside Rust. They do not replace a target-specific sample or certify every language feature.

## Selecting a minimal route

Start with one primary engine and its required metadata/format reader. Add a second engine only to resolve a concrete ambiguity, failed construct or important independent check. An environment-specific helper can recover useful names and types without providing method-body decompilation. Preserve that distinction in the result.

For unsupported versions or representations, return the available structural/instruction evidence and identify the missing decoder or metadata. A model-built adapter can connect existing engines or implement a specified format subset; it cannot recreate erased source facts merely by selecting a source-like output language.

Tool descriptions were checked against upstream documentation on 2026-10-10. Selection still requires a probe of the installed revision and the target; a main-branch feature may not exist in a packaged release.
