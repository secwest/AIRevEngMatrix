# Format fixtures

These synthetic fixtures give parsers and identity checks outside firmware a
known input with a known answer, so a result can be checked against bytes rather
than trusted from an engine's label. They extend the pattern established by the
[firmware fixtures](firmware-fixtures.md) to native, managed, bytecode, web,
protocol, and binary-analysis targets. Each is pure data with no code to execute;
each carries an `expected` block with decoded fields and the result of every
check, and a `limitations` block stating what a passing check does not establish.

Where a format has an integrity field, the fixture's expected value was computed
with the real algorithm (zlib/IEEE CRC32, Adler-32, SHA-1, SHA-256) and recomputed
independently; where a format has no integrity field (a class file, a Mach-O fat
header), the checks are structural and no digest is invented. A fixture pass
establishes the expected outcome for the engine under test; it does not establish
a result on a real artifact, which has its own identity and layering. Keep the
fixture check and the target check as separate outcomes, as the
[coverage map](coverage-map.md) requires.

| Fixture | Format | Decisive check |
| --- | --- | --- |
| [macho-fat.yaml](../assets/fixtures/macho-fat.yaml) | Mach-O universal (fat) header | per-slice cputype/offset; magic collision with the JVM |
| [elf-loadmap.yaml](../assets/fixtures/elf-loadmap.yaml) | ELF64 PT_LOAD | file-backed vs zero-fill address mapping (memsz > filesz) |
| [dex-header.yaml](../assets/fixtures/dex-header.yaml) | Android DEX header | Adler-32 vs SHA-1, separately, vs signing |
| [java-classfile.yaml](../assets/fixtures/java-classfile.yaml) | JVM class file | magic, version mapping, constant-pool decode (no digest) |
| [pyc-header.yaml](../assets/fixtures/pyc-header.yaml) | CPython .pyc header | magic → version, timestamp vs hash-based flags |
| [lua-bytecode-header.yaml](../assets/fixtures/lua-bytecode-header.yaml) | Lua 5.4 luac header | version and endianness/size check-words |
| [wasm-module.yaml](../assets/fixtures/wasm-module.yaml) | WebAssembly module | section inventory, export → function index |
| [sourcemap.yaml](../assets/fixtures/sourcemap.yaml) | Source Map v3 | VLQ mapping with a UTF-16 column, and an unmapped span |
| [structured-records.yaml](../assets/fixtures/structured-records.yaml) | Protobuf wire + CBOR | field numbers/wire types and CBOR structure (not names) |
| [encoded-string.yaml](../assets/fixtures/encoded-string.yaml) | XOR + stack string blob | recovered key/plaintext/offset (not reachability) |
| [evm-dispatch.yaml](../assets/fixtures/evm-dispatch.yaml) | EVM runtime bytecode | PUSH4 selector and dispatch offsets (not the signature) |
| [go-buildinfo.yaml](../assets/fixtures/go-buildinfo.yaml) | Go buildinfo header | sentinel + version string identity |

## Native binaries

The [Mach-O fat fixture](../assets/fixtures/macho-fat.yaml) is a two-slice
universal header (ARM64 and x86_64). `FAT_MAGIC` (`0xCAFEBABE`) is big-endian on
disk, and each `fat_arch` gives a cputype, offset, size, and alignment. The
decisive point is that a universal binary contains distinct per-architecture
code: selecting the wrong slice analyzes the wrong bytes. The fixture also notes
that `0xCAFEBABE` collides with the JVM class magic, disambiguated by byte order
and a plausible `nfat_arch` versus a class file's version `u16`s.

The [ELF load-map fixture](../assets/fixtures/elf-loadmap.yaml) is a minimal
ELF64 with one `PT_LOAD` where `p_memsz` (0x200) exceeds `p_filesz` (0x100). The
two decisive lookups encode the rule that a file-backed address maps back to an
original byte while a zero-fill (`.bss`) address has no invented file offset:
`0x400050` round-trips to file offset `0x50`, and `0x400150` resolves to
synthesized zero with no file offset.

## Managed and bytecode formats

The [DEX fixture](../assets/fixtures/dex-header.yaml) is a 0x70-byte header. Its
Adler-32 (offset 8) covers bytes 12 onward; its SHA-1 signature (offset 12)
covers bytes 32 onward. The cases keep these separate: a valid Adler-32 says
nothing about the SHA-1, and neither establishes APK signing, which is a
different layer. The [JVM class fixture](../assets/fixtures/java-classfile.yaml)
checks `0xCAFEBABE`, the `major_version` → Java-release mapping (61 = Java 17),
the constant-pool count, and one `CONSTANT_Utf8` decode; a class file has no
integrity field, so none is asserted.

The [pyc fixture](../assets/fixtures/pyc-header.yaml) is the 16-byte CPython
header. It checks the 4-byte magic → version (3495 = 3.11), and the PEP 552 flag
bit that selects between a timestamp header (mtime + source size) and a
hash-based header. The marshalled code object is not fabricated; a decoded header
does not establish decompiler support for the opcodes that follow, and a
magic for a different version must be refused, not reinterpreted. The
[Lua fixture](../assets/fixtures/lua-bytecode-header.yaml) is the Lua 5.4 luac
header: signature `\x1bLua`, version `0x54`, the `LUAC_DATA` sentinel, and the
`LUAC_INT` (`0x5678`) and `LUAC_NUM` (`370.5`) check-words that exist precisely to
detect a mismatched loader — a reversed `LUAC_INT` is a rejection case.

The [Wasm fixture](../assets/fixtures/wasm-module.yaml) is a hand-assembled module
exporting one function. It checks the `\0asm` magic and version, the section
inventory (type, function, export, code) with exact LEB128 sizes, the export
name resolving to function index 0, and the body `i32.const 42; end`. A truncated
section (declared size exceeding the remaining bytes) is an error case. Section
ids and indices are recoverable from bytes; original names beyond the export
table are not implied.

The [EVM fixture](../assets/fixtures/evm-dispatch.yaml) is a function-selector
dispatch fragment. It checks the `PUSH4` selector constant (`0xa9059cbb`, the
published keccak-derived selector for `transfer(address,uint256)` — cited, not
recomputed), the `JUMPI` destination, and the `JUMPDEST` it lands on, plus a
`REVERT` fallback. An unknown opcode is marked as an undecoded region, not
guessed. The selector's human-readable signature and parameter names are a
signature-database candidate, not something decoded from the bytes.

## Web, protocol, and binary-analysis artifacts

The [source-map fixture](../assets/fixtures/sourcemap.yaml) is a Source Map v3
with a generated file, its `.map`, and VLQ `mappings`. It checks a decoded
generated→original position, a mapping into a UTF-16 column that follows an
astral emoji (two code units, so the following character sits at column 16, not
15), and a generated span with no mapping. A source map recovers positions and
names only where mappings exist and only once acquired; it does not recover
erased logic.

The [structured-records fixture](../assets/fixtures/structured-records.yaml)
carries one Protobuf message and one CBOR value. For Protobuf it checks each
field's number and wire type and the raw value, and encodes the hedge as a check:
field names and declared types are not recoverable from the wire without the
`.proto`. For CBOR it checks the major types, keys, and values of `{1: "ok",
2: [10, 20]}`; a syntactically decoded value can still have unresolved
application meaning. The [encoded-string fixture](../assets/fixtures/encoded-string.yaml)
is a blob with one XOR-encoded string (key `0x5A` → `SECRET`) and one
stack-constructed string (`flag{ok}`), with each plaintext, key, and offset as
the expected answer. A recovered string is a candidate; it does not establish
that any code path builds or reaches it.

The [Go buildinfo fixture](../assets/fixtures/go-buildinfo.yaml) is the
`\xff Go buildinf:` sentinel header with the inline flag set, followed by
uvarint-length-prefixed strings. It checks the sentinel, the pointer size, and
the decoded version (`go1.21.0`). The sentinel and version are a reliable
identity check from bytes; they do not establish the module dependency graph is
intact or the binary unstripped.

## Using a fixture result

Record the parser or analyzer engine and version, run every case, and compare
the decoded values and validation flags against each fixture's `expected`/`cases`
block. Keep the three states a firmware fixture already distinguishes — parsed,
integrity-valid, and authenticated — distinct here too: a valid DEX Adler-32, a
matching Wasm section inventory, or a decoded selector is structural truth, not
authenticity and not reachability. A fixture pass scores the engine; a result on
a real artifact is a separate outcome with its own digest and layering.
