# Managed code and mobile devices

Managed-code and mobile analysis depend on the available assemblies, packages, devices, and analysis engines. [Graph and evidence conventions](evidence-and-runtime.md) apply to formal cross-layer joins and portable provenance. An engine named here is a candidate dependency; an adapter specification does not establish that a licensed engine or device exists.

Detailed decompiler selection and language lowering follow the [.NET](dotnet-reverse-engineering.md), [JVM/Android](jvm-android-reverse-engineering.md), and [Flutter/game-engine](mobile-game-reverse-engineering.md) workflows. This guide retains the package, device and adapter operations.

## .NET assemblies

1. Detect PE/CLI metadata and deployment form without loading code. Record assembly identity, modules, references, target framework, resources, ReadyToRun/native indicators and original digest. Use dnfile/dnlib, System.Reflection.Metadata, ILSpy APIs, or `ildasm` output.
2. Enumerate TypeDef/TypeRef/MethodDef/MemberRef tables, signatures, generic parameters, custom attributes, method bodies, CIL instructions, exception regions, calls, field access and strings. Resolve tokens within the same exact assembly identity. Decompiled C# is optional producer interpretation; CIL and metadata are primary structural evidence.
3. Identify P/Invoke, DllImport/LibraryImport, UnmanagedCallersOnly, COM and other declared native boundaries. Match a declaration to a supplied native export/import or function only with library name, symbol/ordinal, architecture and calling convention evidence. A declared boundary does not prove runtime binding.
4. Compare two builds using assembly identity and signature/IL normalization; tokens are build-local. Import a reconstruction by binding each recreated member to a uniquely identified original member, then run fixture comparisons. For cross-layer questions, type, method and native-boundary relationships can support a feature explanation.

Validate on a small assembly with a known method, call and P/Invoke. A member query must return its token, signature and instruction span. A native-boundary verifier must report unresolved libraries as unknown.

Deployment form determines the analysis path. A single-file carrier can contain managed assemblies that need extraction before metadata analysis; ReadyToRun can include native code alongside managed material. [Native AOT](https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/) compiles IL into native code at publication, so a CLI metadata parser cannot be assumed to recover its methods as ordinary CIL bodies. Such code follows the [native analysis](native-and-artifacts.md) path, with retained metadata and symbols used where available.

## Android APK and resources

Treat APK/AAB-derived APK bytes as ZIP carriers. Read manifest, signing metadata, DEX files, resources.arsc, native libraries, assets and split relationships with bounded parsers. `aapt2`, `apkanalyzer`, Apktool, JADX or equivalent installed engines can provide decoded resources and code. Keep original XML/resource IDs and decoded values linked. Decompilation is a producer report; DEX method/class descriptors and bytecode offsets anchor claims.

For code workflows, implement package summary, class search, class/method inspection and reference tracing by indexing DEX descriptors, method IDs, call instructions, fields and strings. Where JADX provides higher-level Java, keep a link back to DEX identity and record failures on obfuscated or malformed code. Resolve reflection, dynamic loading and JNI only as far as evidence allows. A cross-layer feature explanation can join manifest components, intent filters, resources, Java/Kotlin classes, native libraries and device observations through exact package/build identities.

Apktool resource decoding is a separate adapter: probe the executable, decode into an isolated directory, hash output, preserve decode diagnostics and map decoded paths to APK members. Do not assume a readable smali/Java reconstruction is behaviorally equivalent to the original.

## ADB device operations

Probe `adb version` before device access. Select a device by explicit serial and verify its state. Use fixed argument arrays; never splice caller strings into a shell command. Record host adb version, device serial, Android build fingerprint, package version/signature where available, operation time and any implicit adb server startup. Inventory devices, features, services, display/window state, packages, processes, directories, settings and bounded logcat through read operations. Package resolution is a search over installed package names and metadata, with exact candidates returned.

Acquisition: query package paths, pull each split/base APK or requested file, hash local bytes, and record remote path/size when available. Screenshot capture uses `exec-out screencap -p` or documented equivalent and records dimensions/hash. Bugreports and logs can contain secrets; select and redact appropriately.

State-changing adapters are separate: push file, install/uninstall package, start app/activity, stop app, and setting changes. Their effects depend on authorization and device controls. `adb shell pm` quoting differs from host shell escaping. Postconditions include installed version or process state; partial changes remain visible in the result.

An install operation identifies the complete selected APK/split set, user/profile and replacement options before invocation; incompatible or missing splits remain explicit failures. Uninstall reports the requested data-retention semantics and observed package state. File push specifies the destination and overwrite behavior and verifies available remote metadata or digest after transfer. Launch/stop operations distinguish a package launcher action from a named activity/intent and verify available process/activity state. A successful transport command and a verified application-level postcondition are separate results.

## JEB integration

JEB is a licensed analysis engine with its own client, project and item identities. Its integration probes the client/version, opens an existing project or import through the documented API, enumerates units, and retains item IDs and raw decompiler output. JADX and other engines may answer a generic code question, but their output does not support a JEB-specific claim.

## Acceptance examples

Fixtures: the [DEX header fixture](../assets/fixtures/dex-header.yaml) checks the Adler-32 and SHA-1 ranges separately (and that neither establishes APK signing), the [JVM class fixture](../assets/fixtures/java-classfile.yaml) checks magic, version mapping, and a constant-pool decode, and the [.NET metadata fixture](../assets/fixtures/dotnet-metadata.yaml) makes the first acceptance example checkable — the `BSJB` root, stream directory, and `#~` table bitvector decode while every MethodDef RVA is 0 (no CIL body), and AOT/ReadyToRun images route to native analysis; see [format fixtures](format-fixtures.md).

- A known .NET fixture yields correct method signature, CIL call and native declaration without loading the assembly.
- An APK's decoded manifest package/version resolves to original resource IDs and the APK digest.
- A pulled APK's local digest is recorded and split acquisition is complete or explicitly partial.
