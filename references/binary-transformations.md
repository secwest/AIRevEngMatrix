# Binary identification, transformation, and patch verification

Template: [binary transformation](../assets/templates/binary-transformation.yaml). Transformations preserve the original artifact and create independently identified outputs. Analysis-database annotations, file edits, and live memory writes are separate operations.

## Components

| Component | Role | Boundary |
| --- | --- | --- |
| [Detect It Easy](https://github.com/horsicq/Detect-It-Easy) and [YARA](https://github.com/VirusTotal/yara)-compatible rules | Format/compiler/packer identification and located pattern candidates | Record tool/rules versions and supporting offsets; signatures are evidence with false-positive and coverage limits. |
| [Capstone](https://www.capstone-engine.org/) | Decode instructions in a declared architecture/mode | Instruction decoding does not establish function boundaries, reachability or program semantics. |
| [Keystone](https://github.com/keystone-engine/keystone) or the selected architecture's assembler | Encode a specified instruction sequence | Record assembler version, mode, origin, syntax, relocations and range constraints; validate emitted bytes with an independent decode. |
| [Unicorn](https://www.unicorn-engine.org/) | Execute bounded machine-code snippets with supplied state | CPU emulation needs explicit memory, registers and hooks. It does not provide the original OS or board. |
| [LIEF](https://lief.re/doc/latest/), LLVM binary utilities | Parse/rebuild supported executable structures or sections | Each write operation's format support and preservation behavior need checking. Rebuilding can alter layout beyond the intended bytes. |
| [UPX](https://github.com/upx/upx) or another identified unpacker | Reverse a supported packaging transform | Verify the exact packer/format first. Static unpacking and runtime extraction have different effects and completeness. |

Tool sources and installed versions are verified before installation/use. Prefer the maintained project repository or vendor documentation over an unverified redirect or similarly named package.

## Identify and unpack

Hash the original and map container/section/overlay boundaries. Corroborate a packer or compiler signature with structural facts and entry behavior. High entropy can also reflect compression, media, encryption or tables. Record nested layers, input/output offsets where meaningful, and every transform's parameters and digest.

Static unpackers run on a copy with output bounds. If dynamic extraction is needed, use the established [runtime method](native-and-artifacts.md), retain load maps and distinguish captured memory from a rebuilt executable. Missing imports/relocations/headers are explicit reconstruction work. Successful loading of a recovered artifact does not establish that every hidden module was recovered.

## Patch or reconstruct a bounded artifact

1. State the intended behavior change or reconstruction property and the exact authorized artifact. Record original bytes, coordinate system, expected original value, and destination output.
2. Describe affected code/data, instruction boundaries, branch reach, relocations, references, ABI, alignment, permissions, checksums and signatures. A code cave requires evidence of unused mapped space and appropriate runtime permissions.
3. Apply the minimal change to a copy through a compatible assembler/editor. Verify the original-byte precondition before writing. Record all changed ranges, including tool-induced layout changes.
4. Reparse the complete output. Independently disassemble changed instructions and validate branch targets, file/address mappings, imports, relocations and format invariants. Signature invalidation or changed integrity fields are reported as changed state.
5. Exercise the requested behavior and relevant unchanged cases in a bounded environment if execution is part of the result. A byte diff alone does not establish behavioral correctness. Retain original and output digests and a repeatable transformation record.

**Deliverable:** transformed artifact, exact delta, reconstruction/patch procedure, structural checks and scoped behavior results. A file patch does not imply flashing a device, updating installed software, or writing live memory.

## Snippet harness

For a small emulated function, specify architecture/mode, code/data maps, permissions, initial registers, stack, calling convention, stop address/condition, and finite instruction/time limits. Model every accessed external function/peripheral explicitly. Compare arithmetic widths, flags, memory writes, and return values against an independent fixture. Unsupported instructions and uninitialized reads remain failures or stated assumptions.

An assembly/disassembly round trip checks encoding under the selected mode. It does not prove that the sequence is valid at its proposed location or preserves the surrounding function's behavior. The [x86-64 decode fixture](../assets/fixtures/asm-roundtrip.yaml) supplies a known instruction stream with its objdump-confirmed decode for the independent-decode check; the encode direction (assembling back to the same bytes) is what a tool like Keystone validates, and an assembler may pick an equivalent encoding, so an encode check compares semantics, not only bytes (see [format fixtures](format-fixtures.md)).
