# Custom formats and additional runtimes

This guide covers declarative binary parsers, WebAssembly, JVM classes, Python bytecode, and Go runtime metadata. Native code, .NET, Android, and JavaScript retain their existing [capability routes](capability-index.md).

## Engine selection

| Engine | Useful output | Conditions |
| --- | --- | --- |
| [Kaitai Struct](https://doc.kaitai.io/user_guide.html) | Declarative format description and generated parser | Pin compiler/runtime versions and language target. Bounded input, nesting, allocation, and validation remain part of the parser design. |
| [wasm-tools](https://github.com/bytecodealliance/wasm-tools) | Validated modules, textual instructions, section metadata, and component interfaces | Record enabled proposals/features and distinguish core modules from components. Host imports and runtime behavior require separate analysis. |
| [Vineflower](https://github.com/Vineflower/vineflower) | Reconstructed Java from supported class/JAR inputs | Match supported class-file version and dependencies. Decompiled Java does not recover original source language, comments, or all compiler intent. |
| [xdis](https://github.com/rocky/python-xdis) | Cross-version Python bytecode and code-object inspection | Identify implementation, magic number, and bytecode version. Support for disassembly does not imply source decompilation for that version. |
| [GoReSym](https://github.com/mandiant/GoReSym) | Available Go function/type/source metadata and address ranges | Check format, architecture, and Go metadata layout support; missing or damaged runtime metadata leaves gaps. |

## From unknown bytes to a format specification

Templates: [format study](../assets/templates/format-study.yaml), [synthetic Kaitai format](../assets/templates/framed-record.ksy), and [format fixtures](../assets/templates/framed-record-fixtures.yaml).

Begin with independently varying samples and a byte map. For each proposed field, record absolute or parent-relative offset, length, endianness, signedness, alignment, and observed values. Distinguish constants, counters, lengths, offsets, tags, compressed payloads, checksums, and unknown bytes. Changes that correlate with a UI action are leads until the encoding is checked.

A parser specification includes:

- Validated signatures and version-dependent layouts.
- Length/offset bounds checked against the containing region before reads or allocation.
- Record count, recursion, decompression, and total-output limits where the format can expand.
- Rules for alignment, duplicate fields, unknown tags, padding, trailing data, and malformed input.
- Checksum coverage and stored/calculated values, separately from any cryptographic authenticity claim.

Kaitai Struct expresses layouts and generates parsers. Compiler options and runtime behavior matter, including lazy instances, validation, and how parse errors expose offsets. A wrapper can enforce input size and exact end-of-input when the format requires it. Serialization support depends on the selected compiler/backend; a parser alone does not supply a rewriter.

The included `framed-record.ksy` is a complete synthetic little-endian record example: fixed magic, version, bounded payload length, and payload. Its fixtures include a valid record, bad magic, unsupported version, excessive length, truncation, and trailing bytes. The trailing-byte case demonstrates a wrapper-level exact-consumption check. It is a teaching fixture, not a recognized vendor format.

**Deliverable:** the recovered field specification, parser source or schema, decoded records with source ranges, positive/negative fixtures, and unresolved fields. Round trips are useful when an encoder exists; they do not replace checks against independently understood samples.

## WebAssembly

Template: [runtime study](../assets/templates/runtime-study.yaml), family `wasm`.

1. Hash and identify the core module/component; preserve container and member coordinates if embedded.
2. Validate with recorded feature settings. Export readable instructions and relevant section/type/import/export/table/memory metadata. `wasm-tools validate`, `print`, and `objdump` provide complementary outputs; component WIT inspection applies to components with suitable interface information.
3. Trace an export through direct and indirect calls, tables, globals, and linear-memory accesses. Keep function/type indices and byte offsets distinct. Names from a name section are optional metadata.
4. Resolve host imports against the actual embedding application or documented runtime. Memory reads/writes and external effects across that boundary require an ABI and ownership interpretation.
5. If execution is required, select a compatible runtime and provide the exact imports, limits, and inputs. A validated module can still trap or behave differently under another host implementation.

For readable pseudocode, [WABT](https://github.com/WebAssembly/wabt) includes `wasm-decompile`; check feature support and keep its output mapped to the original module. It does not restore the original Rust, C, or other source language.

**Deliverable:** interface and code explanation, decisive instruction/index locations, host-boundary dependencies, and optional runtime checks. Text output is a representation of the module, not recovered high-level source.

## JVM classes and archives

Template: [runtime study](../assets/templates/runtime-study.yaml), family `jvm`.

Inventory JAR/ZIP members, multi-release variants, nested archives, manifest entries, class versions, and native libraries. Select the class variant corresponding to the target runtime. Resolve methods using class identity, name, and descriptor; overloads and bridge/synthetic methods remain distinct.

Use Vineflower or [CFR](https://www.benf.org/other/cfr/) for supported readable reconstruction and retain the exact options, dependency classpath, diagnostics, and input/output mapping. Check decisive branches, exception tables, invokedynamic/bootstrap relationships, and field/method references against bytecode. Static initializers, reflection, classloader behavior, and JNI form runtime boundaries. Static inspection does not initialize classes or launch a JAR. The [language guide](language-decompilation.md) distinguishes Java-shaped output from recovery of original Kotlin/Scala constructs.

**Deliverable:** class/method inventory, reconstructed code, descriptor-anchored call paths, unresolved dynamic dependencies, and bytecode checks. A successfully recompiled reconstruction is an additional check, not proof of equivalent behavior.

## Python bytecode and packaged applications

Template: [runtime study](../assets/templates/runtime-study.yaml), family `python`.

Identify the packaging layer and bytecode implementation/version first. Preserve extraction provenance for embedded modules and native extensions. A packaging extractor is selected separately for the identified container; xdis's role is bytecode analysis.

Inspect headers, code objects, constants, names, nested functions, imports, instruction offsets, exception structures, and line information using supported version semantics. Avoid importing recovered modules to inspect them. Bytecode and marshal-like structures remain untrusted parser inputs. Adaptive instructions and inline caches make naive opcode arithmetic unreliable across versions.

Build function/module relationships from code-object identities and instruction references. Select pycdc, uncompyle6 or decompyle3 only when the engine supports the actual bytecode version and relevant constructs; xdis disassembly support does not imply source recovery. The [VM guide](virtual-machines.md) covers engine/version selection and packaged bytecode. Native extensions and dynamic imports route to the corresponding analysis family.

**Deliverable:** package/module inventory, version-qualified disassembly, code-object relationships, and reconstruction limits. Unsupported bytecode remains explicitly unsupported.

## Go metadata recovery

Template: [runtime study](../assets/templates/runtime-study.yaml), family `go`.

Run GoReSym against exact bytes and preserve its structured output. Record supported build/runtime metadata, function ranges/names, source mappings, and types when recovered. Verify representative function boundaries against a disassembler and reconcile file/image/load coordinates before importing names into an analysis database.

Compiler/runtime versions affect ABI, stack growth, interfaces, closures, and scheduler routines. A recovered name helps identify a candidate function but does not prove its semantics or source availability. cgo and assembly boundaries require native calling-convention checks. Symbol import is a database mutation with its own readback and collision policy.

**Deliverable:** recovered metadata, checked address mappings, function/type annotations where requested, and gaps caused by stripping, packing, or unsupported layouts.
