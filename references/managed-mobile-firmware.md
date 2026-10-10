# Managed code, mobile devices, and firmware build recipes

Build only what the requested result needs. Use [graph and evidence conventions](evidence-and-runtime.md) when formal cross-layer joins or portable provenance are needed. An engine listed here is a candidate dependency; probe the installed version and API. Do not present an adapter specification as evidence that a licensed engine or device exists.

## .NET assemblies

1. Detect PE/CLI metadata and deployment form without loading code. Record assembly identity, modules, references, target framework, resources, ReadyToRun/native indicators and original digest. Use dnfile/dnlib, System.Reflection.Metadata, ILSpy APIs, or `ildasm` output.
2. Enumerate TypeDef/TypeRef/MethodDef/MemberRef tables, signatures, generic parameters, custom attributes, method bodies, CIL instructions, exception regions, calls, field access and strings. Resolve tokens within the same exact assembly identity. Decompiled C# is optional producer interpretation; CIL and metadata are primary structural evidence.
3. Identify P/Invoke, DllImport/LibraryImport, UnmanagedCallersOnly, COM and other declared native boundaries. Match a declaration to a supplied native export/import or function only with library name, symbol/ordinal, architecture and calling convention evidence. A declared boundary does not prove runtime binding.
4. Compare two builds using assembly identity and signature/IL normalization; tokens are build-local. Import a reconstruction by binding each recreated member to a uniquely identified original member, then run fixture comparisons. For cross-layer questions, type, method and native-boundary relationships can support a feature explanation.

Validate on a small assembly with a known method, call and P/Invoke. A member query must return its token, signature and instruction span. A native-boundary verifier must report unresolved libraries as unknown.

## Android APK and resources

Treat APK/AAB-derived APK bytes as ZIP carriers. Read manifest, signing metadata, DEX files, resources.arsc, native libraries, assets and split relationships with bounded parsers. `aapt2`, `apkanalyzer`, Apktool, JADX or equivalent installed engines can provide decoded resources and code. Keep original XML/resource IDs and decoded values linked. Decompilation is a producer report; DEX method/class descriptors and bytecode offsets anchor claims.

For code workflows, implement package summary, class search, class/method inspection and reference tracing by indexing DEX descriptors, method IDs, call instructions, fields and strings. Where JADX provides higher-level Java, keep a link back to DEX identity and record failures on obfuscated or malformed code. Resolve reflection, dynamic loading and JNI only as far as evidence allows. A cross-layer feature explanation can join manifest components, intent filters, resources, Java/Kotlin classes, native libraries and device observations through exact package/build identities.

Apktool resource decoding is a separate adapter: probe the executable, decode into an isolated directory, hash output, preserve decode diagnostics and map decoded paths to APK members. Do not assume a readable smali/Java reconstruction is behaviorally equivalent to the original.

## ADB device operations

Probe `adb version` before device access. Select a device by explicit serial and verify its state. Use fixed argument arrays; never splice caller strings into a shell command. Record host adb version, device serial, Android build fingerprint, package version/signature where available, operation time and any implicit adb server startup. Inventory devices, features, services, display/window state, packages, processes, directories, settings and bounded logcat through read operations. Package resolution is a search over installed package names and metadata, with exact candidates returned.

Acquisition: query package paths, pull each split/base APK or requested file, hash local bytes, and record remote path/size when available. Screenshot capture uses `exec-out screencap -p` or documented equivalent and records dimensions/hash. Bugreports and logs can contain secrets; select and redact appropriately.

State-changing adapters are separate: push file, install/uninstall package, start app/activity, stop app, change settings if explicitly requested. Describe target effect and use the user's authorization and device controls. Do not conflate `adb shell pm` quoting with host shell escaping. Verify postconditions such as installed version or process state and report partial changes.

## JEB integration

JEB is a licensed, running producer, not something the skill can reproduce. If available, probe its client/version, open an existing project or import with its documented API, enumerate units, decompile selected items, and retain JEB item IDs and raw output. Do not silently fall back from JEB-specific claims to JADX or another engine. A generic question may use another available engine if it supports the needed fact; a JEB-specific request requires JEB.

## Firmware

Inspect regions with an installed signature scanner such as Binwalk, then confirm boundaries and signatures against raw bytes. Report offset, length if known, candidate format, confidence and overlap. For extraction, use a format-specific parser or Unblob in a bounded output directory, preserve parent offset and extractor version, reject path escapes and decompression bombs, and hash every extracted child. Filesystems, kernels, archives and native executables then feed their appropriate analyzers as new artifacts. A signature hit is not proof that a full valid filesystem exists; extraction success and structure checks raise confidence. Never mount or execute firmware as a side effect of static inspection.

## Acceptance examples

- A known .NET fixture yields correct method signature, CIL call and native declaration without loading the assembly.
- An APK's decoded manifest package/version resolves to original resource IDs and the APK digest.
- A pulled APK's local digest is recorded and split acquisition is complete or explicitly partial.
- A firmware extraction's children remain inside its output directory and retain parent offset provenance.
