# Flutter and game development environments

These ecosystems combine code with engine-specific metadata and resources. The code/metadata/resource pairings are part of the target identity. Records: [environment study](../assets/templates/environment-study.yaml), [VM study](../assets/templates/virtual-machine-study.yaml).

## Engines and supporting efforts

| Environment | Candidate efforts | Supported result and qualification |
| --- | --- | --- |
| Dart/Flutter AOT | [Blutter](https://github.com/worawit/blutter), native decompiler | Upstream's documented route targets Android ARM64 `libapp.so` and compatible recent Dart versions. Host OS support does not extend the target architecture/format range. |
| Unity Mono | ILSpy/dnSpyEx and a compatible serialized-resource reader | Managed code follows [.NET](dotnet-reverse-engineering.md); assets need exact Unity format/type information. |
| Unity IL2CPP | [Cpp2IL](https://github.com/SamboyCoding/Cpp2IL), [Il2CppDumper](https://github.com/Perfare/Il2CppDumper), native decompiler | Type/method mappings and supported reconstruction from paired native code/metadata. Stub assemblies may have no recovered bodies. |
| Unreal native/assets | [CUE4Parse](https://github.com/FabianFG/CUE4Parse), FModel, native C++ engine | Parse supported packages/resources; native gameplay code uses the [C++ workflow](cpp-reverse-engineering.md). |
| Unreal Blueprints | [KismetKompiler](https://github.com/tge-was-taken/KismetKompiler) | Experimental, version-sensitive Blueprint reconstruction to its own syntax. Upstream emphasizes UE4.23 testing and incomplete constructs; do not infer blanket UE5 support. |
| Godot | [GDRE Tools](https://github.com/GDRETools/gdsdecomp) | Supported PCK/project/resource and GDScript recovery; C#, native extensions and encrypted/unsupported members need separate routes. |

## Dart and Flutter

Identify JIT/kernel data versus native AOT and retain the matching engine, application image, snapshot data and package resources. A Dart snapshot begins with the magic constant `0xDCDCF5F5`, serialized in host (little-endian) order as bytes `F5 F5 DC DC`, then an int64 length and an int64 kind (`kFull`=0, `kFullJIT`=1, `kFullAOT`=2, `kModule`=3) in a 20-byte header; a per-build version/"snapshot hash" string follows, and the VM rejects a snapshot whose hash does not match the loading engine. Read that hash from the artifact to pin the Dart/Flutter SDK before selecting Blutter; it changes per build and is not portable. For Blutter, probe target and Dart-version compatibility before setup; its workflow can fetch and build matching Dart runtime code. Record those dependencies and generated artifacts.

Recover object pools, class/function metadata and native addresses where supported. Check tagged values, pointer representation, allocation calls, async state and generic/type metadata against instructions. Trace platform channels and FFI into their actual native handlers. Obfuscation, tree shaking and inlining can erase source boundaries.

The [Dart fixture](../assets/fixtures/environment-patterns.dart) exercises an interface and async/error paths. [JIT/AOT profiles](environment-fixtures.md) provide a small compiler comparison. A desktop Dart executable does not validate Blutter's Flutter Android route; for that assessment, embed the case in a matching Flutter app and retain its complete engine/application pair.

## Unity

Identify Mono versus IL2CPP from actual files. Match the native binary, metadata, architecture, Unity version, registration tables and asset schema. Avoid mixing metadata from a nearby build. Generic sharing and method pointers can make several managed methods refer to the same native body. The [IL2CPP metadata fixture](../assets/fixtures/il2cpp-metadata.yaml) checks the `0xFAB11BAF` `global-metadata.dat` magic and the version field that gates the header layout — read before any section offset is dereferenced and before Cpp2IL/Il2CppDumper selection — while asserting the paired `libil2cpp`/`GameAssembly` match is a separate check (see [format fixtures](format-fixtures.md)).

Check representative recovered addresses and method signatures in native instructions. Classify each output as declaration, stub, reconstructed IL or native pseudocode. Join script/type IDs to serialized assets using package evidence; an asset name does not resolve the invoked method.

Build a tiny project with one serialized field, generic method, coroutine and native boundary when relevant. Export Mono and IL2CPP separately, preserve build settings, then compare observable cases and actual body recovery. The supplied C# fixture only checks language behavior until it is built through Unity.

## Unreal and Godot

For Unreal, bind engine/custom serialization versions, package dependencies, name/object tables, property mappings and code modules. Trace Blueprint bytecode/event entry to the native reflection target using exact object/function identities. A package parser can expose assets while leaving execution semantics unresolved. KismetKompiler's own round-trip checks are evidence to retain, not a universal engine-equivalence proof.

For Godot, identify PCK/project and bytecode versions, script language, native extensions and resource/scene links. Recover supported GDScript and project structure with GDRE Tools, preserving failed members and transformation logs. Do not execute recovered editor plugins during inspection. C# uses managed or Native AOT analysis according to the shipped representation.

A representative engine fixture has one event, script method, resource reference and failure branch. Compare the recovered graph/bytecode and selected run in the matching engine. Add malformed resource or missing dependency cases when the parser is part of the toolkit.

**Deliverable:** code/metadata/resource map, reconstructed supported methods/scripts, package coordinates, engine-specific checks and explicit unrecovered bodies. Project recovery, asset extraction and method decompilation have separate outcomes.
