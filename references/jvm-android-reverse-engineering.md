# JVM and Android development environments

Scope: Java, Kotlin and Scala on the JVM; Android DEX; JNI; and native publication from these ecosystems. Records: [environment study](../assets/templates/environment-study.yaml) and [decompilation study](../assets/templates/decompilation-study.yaml).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| [Vineflower](https://github.com/Vineflower/vineflower) | JVM decompilation with language plugins in supported distributions | Its [release notes](https://github.com/Vineflower/vineflower/releases/) document Kotlin work and differences between regular and slim distributions. Record the actual plugin set. |
| [CFR](https://www.benf.org/other/cfr/) | Alternative class/JAR decompilation | Check class-file features and dependency resolution on the selected version. |
| `javap`, class-file readers | Bytecode, descriptors, constant pools and exception-table checks | Use the selected runtime's class variant; loading classes is unnecessary for static inspection. |
| [JADX](https://github.com/skylot/jadx), JEB | DEX/package decompilation and navigation | Java-like output can misrepresent Kotlin lowering or damaged control flow. Preserve DEX offsets and errors. |
| Apktool, Android package tools, smali/baksmali | Resources, manifest and DEX-level representations | These roles complement high-level decompilation. Device acquisition follows [mobile methods](managed-mobile-firmware.md). |

## Intake and workflow

1. Inventory JAR/WAR/AAR/APK members, nested archives, multidex and split packages. Record class/DEX versions, multi-release JAR selection, Kotlin/Scala metadata, resources and native libraries. Keep original member paths and hashes.
2. Select JVM versus DEX decoding from the actual bytes. Java/Kotlin can also produce native executables, JavaScript or Wasm; those outputs require their corresponding routes. A GraalVM Native Image is not an ordinary JAR with universally recoverable bytecode: it is an AOT-compiled SubstrateVM binary (ELF/PE/Mach-O) that does not run on HotSpot, so analyze it as a native binary through [native analysis](native-and-artifacts.md). Its recoverable surface is the SubstrateVM image heap — an embedded object graph carrying class/method/field name strings used for reflection/JNI/serialization plus resource bytes, often readable as embedded data. The reachability metadata (legacy per-feature `reflect-config.json`, `jni-config.json`, `serialization-config.json`, `resource-config.json`, consolidated into `reachability-metadata.json` as of GraalVM for JDK 23) lives under `META-INF/native-image` as a build input; it is not guaranteed to appear in the shipped executable, only its compiled effect in the image heap. If the original application jar ships alongside, that JSON is readable there.
3. Identify a method by owner, name and descriptor within the exact artifact. Preserve overloads, synthetic bridges and erased/generic signatures separately.
4. Decompile with the required dependency classpath and supported language plugin. Retain a raw instruction view for incomplete methods and instruction-to-output mappings where available.
5. Trace allocations, dispatch, exceptions, bootstrap methods and dynamically selected classes. For Android, join components/resources to DEX callbacks and JNI registrations using actual identifiers.
6. Check decisive branches and exception paths against bytecode, then validate the requested behavior under the chosen runtime or device. Reflection, class initialization and dynamic class loading can leave static gaps.

## Constructs needing explicit interpretation

| Family | Recovery and checks |
| --- | --- |
| Java | Lambdas/invokedynamic, bridges, records, switch lowering, try-with-resources, suppressed exceptions and monitor release |
| Kotlin/JVM | Metadata, default-argument masks, null checks, suspend continuations, inline/value classes and compiler-generated accessors; Kotlin output requires compatible plugin support |
| Scala | Versioned Scala metadata/TASTy when present, closures, pattern matches, module objects and specialized methods; Java output is only one view |
| Android | R8/ProGuard mappings when supplied, merged/inlined methods, resource shrinking, desugaring, lifecycle and coroutine scheduling |
| JNI/native output | Registration tables, library/ABI selection, ownership and exception crossing; use the native engine for method bodies |

## Representative assessment

The [Java fixture](../assets/fixtures/EnvironmentPatterns.java) covers interface dispatch, generics, a lambda and exception handling. Its [profiles](environment-fixtures.md) retain or omit debug data. A JVM Java fixture does not establish DEX or Kotlin/Scala reconstruction quality.

For Android, compile a small feature into an APK with the target toolchain and preserve its mapping/resources; compare unminified and minified builds. For Kotlin, add suspension plus a default argument and nullable value. For Scala, add a pattern match and captured closure. Validate each generated method and failed/deferred path; record any untested profile.

Kotlin declarations carry a `@kotlin.Metadata` annotation that recovers the real Kotlin shape a Java-oriented decompiler flattens: `k` is the kind (1 class, 2 file facade, 3 synthetic class, 4 multi-file facade, 5 multi-file part), `mv` the metadata version, `d1` the protobuf-encoded declaration data, and `d2` the string table `d1` indexes by integer. Decode it with the `kotlin-metadata-jvm` library rather than inferring Kotlin constructs from the Java-shaped output; a class without this annotation (or with an unrecognized `k`) is treated as non-Kotlin.

**Deliverable:** reconstructed supported methods, bytecode anchors, checked generated constructs, resource/native relationships and unresolved loader behavior. Missing names or source syntax stay explicit even when bytecode behavior is understood.
