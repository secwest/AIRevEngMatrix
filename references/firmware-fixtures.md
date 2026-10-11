# Firmware fixtures

These synthetic fixtures give firmware parsers and base-inference logic a known
input with a known answer, so a result can be checked against bytes rather than
trusted from a scanner label. They parallel the [Rust](../assets/fixtures/rust-patterns.yaml)
and [environment](environment-fixtures.md) fixtures: the fixture is checkable on
its own, while assessing a real tool additionally requires that tool's version,
settings, and output against the actual target. Each fixture is pure data with
no code to execute. See [firmware structure](firmware.md) and the
[firmware lab](firmware-lab.md) for the methods these support.

Each fixture carries an `expected` block with the decoded fields and the result
of every check, and a `limitations` block stating what a passing check does not
establish. Where a format has an integrity field, the fixture's expected value
was computed with the standard algorithm (zlib/IEEE CRC32, a 16-bit modular sum,
a 1-byte XOR, or SHA-256) so a parser can be scored against it; where a field
uses an algorithm that needs an independent oracle to confirm (ext4's crc32c),
the method is documented and no value is asserted.

| Fixture | Format | Decisive check |
| --- | --- | --- |
| [firmware-uimage.yaml](../assets/fixtures/firmware-uimage.yaml) | U-Boot legacy uImage | header CRC32 vs payload CRC32, separately |
| [firmware-cortexm.yaml](../assets/fixtures/firmware-cortexm.yaml) | ARMv7-M vector table | load-base inference from SP/reset/handlers |
| [firmware-gpt.yaml](../assets/fixtures/firmware-gpt.yaml) | GUID Partition Table | header CRC32 and entry-array CRC32 |
| [firmware-intel-hex.yaml](../assets/fixtures/firmware-intel-hex.yaml) | Intel HEX | record checksum; holes and non-contiguous regions |
| [firmware-android-sparse.yaml](../assets/fixtures/firmware-android-sparse.yaml) | Android sparse image | expansion + CRC32 of the expanded image |
| [firmware-android-boot.yaml](../assets/fixtures/firmware-android-boot.yaml) | Android boot image v4 | header offsets and os_version bit packing |
| [firmware-dtb.yaml](../assets/fixtures/firmware-dtb.yaml) | Flattened devicetree | header alignment and structure-block token walk |
| [firmware-ext4-superblock.yaml](../assets/fixtures/firmware-ext4-superblock.yaml) | ext4 superblock | magic, block-size formula, revision gate (structural) |
| [firmware-mcuboot.yaml](../assets/fixtures/firmware-mcuboot.yaml) | MCUboot image | SHA-256 TLV coverage (header + payload + protected TLVs) |
| [firmware-uefi-fv.yaml](../assets/fixtures/firmware-uefi-fv.yaml) | UEFI firmware volume | 16-bit header checksum over HeaderLength |
| [firmware-esp32.yaml](../assets/fixtures/firmware-esp32.yaml) | ESP32 application image | 1-byte XOR checksum + appended SHA-256 |

## uImage header fixture

[`assets/fixtures/firmware-uimage.yaml`](../assets/fixtures/firmware-uimage.yaml)
holds four synthetic U-Boot legacy image headers. The header is 64 big-endian
bytes; the header CRC covers the 64-byte header with its own CRC field zeroed,
and the data CRC covers only the payload. The cases separate outcomes that are
easy to conflate:

| Case | What it checks |
| --- | --- |
| `valid` | Magic, size, both CRC32 values, and the OS/arch/type/compression fields all decode correctly |
| `bad_data_crc` | A one-byte payload change leaves the header CRC valid but fails the data CRC: header integrity is not payload integrity |
| `truncated_payload` | The header declares 64 payload bytes but only 40 follow; a parser must report a short-input error, not zero-fill and compute a CRC over invented bytes |
| `bad_magic` | A flipped magic byte must be rejected before any later field is trusted |

A correct parser verifies magic, reads the declared size, recomputes both CRC32
values (zlib/IEEE polynomial) over the right byte ranges, and keeps three states
distinct: header parsed, header CRC valid, payload CRC valid. A passing CRC
establishes none of authenticity, signing, or active boot selection; those are
analyzed at their own layers. The fixture carries no FIT wrapper, signature, or
compression, so it exercises header decoding and CRC validation only.

## Cortex-M vector table fixture

[`assets/fixtures/firmware-cortexm.yaml`](../assets/fixtures/firmware-cortexm.yaml)
holds a 144-byte ARMv7-M image fragment intended to load at flash address
`0x08000000`. Word 0 is the initial main stack pointer and word 1 is the reset
vector; all Cortex-M vectors are Thumb, so bit 0 is set and the instruction
address is the value with bit 0 cleared.

Treating file offset 0 as a vector table, the base-inference check is the mutual
consistency of several references, not one disassembled instruction:

- the initial SP (`0x20001000`) resolves into a plausible RAM region;
- the reset vector (`0x08000081`, Thumb) resolves into flash at the intended base;
- multiple handler vectors share that base; and
- reserved slots are zero and are not read as code addresses.

Together these support a `0x08000000` load base. The fixture records this as a
hypothesis about an image offset: device remapping, such as a boot-ROM alias at
`0x00000000`, can change the effective base, and a single matching instruction
would not establish it. The image models no peripherals, clocks, or boot ROM;
its two short code stubs exist only so reset and handler targets point at
decodable Thumb. Any execution claim uses the
[firmware experiment](../assets/templates/firmware-experiment.yaml) route instead.

## Partition tables and record formats

The [GPT fixture](../assets/fixtures/firmware-gpt.yaml) is a primary header plus a
four-entry partition array. It checks the two independent CRC32s — the header
CRC32 is computed over `HeaderSize` bytes with its own field zeroed, the array
CRC32 over `NumberOfPartitionEntries * SizeOfPartitionEntry` bytes — and the
mixed-endian GUID encoding (Data1/2/3 little-endian, Data4 in text order). The
first entry decodes to an EFI System Partition at LBA 34–37; the three zero
entries are unused but still covered by the array CRC. Real disks use 128
entries; the compact count is spec-valid because each CRC covers exactly the
declared range. A valid pair of CRC32s does not establish the partitions exist
on a device or that it would boot, and the backup header has its own CRCs.

The [Intel HEX fixture](../assets/fixtures/firmware-intel-hex.yaml) exercises the
per-record checksum (every record byte including the checksum sums to zero mod
256) and address reconstruction through a type-04 extended-linear-address record.
It deliberately leaves an eight-byte hole and then jumps to `0x08010000`, so
concatenating the record payloads in file order produces a false memory image:
a correct reader places each record at its own address and reports the hole and
the gap rather than filling them. The same caution applies to S-records, UF2,
and TI-TXT.

## Paged and container images

The [Android sparse fixture](../assets/fixtures/firmware-android-sparse.yaml) is a
header plus RAW, FILL, and DONT_CARE chunks. The expander copies RAW data,
repeats the FILL pattern, and emits zeros for DONT_CARE; the `image_checksum` is
the CRC32 of the expanded image with DONT_CARE regions counted as zeros, so a
parser can be scored end to end. The [Android boot v4 fixture](../assets/fixtures/firmware-android-boot.yaml)
is a header only: it checks the fixed offsets, the `os_version` bit packing
(13.0.0, patch 2024-08), and the 4096-byte page layout. v3/v4 carry no in-header
checksum and no load addresses — those come from vendor_boot — so a parsed
header does not establish the referenced images are present, signed, or accepted.

The [DTB fixture](../assets/fixtures/firmware-dtb.yaml) is a minimal version-17
flattened devicetree for `/{ #address-cells = <1>; }`. It checks the big-endian
header, the 8-byte alignment of the reservation block and 4-byte alignment of the
structure block, the token walk (BEGIN_NODE, PROP, END_NODE, END), and
`totalsize == length`. A DTB has no CRC; FIT integrity comes from hash subnodes,
checked separately. A structurally valid DTB describes intended hardware, not the
board actually connected.

The [ext4 superblock fixture](../assets/fixtures/firmware-ext4-superblock.yaml) is
structural: magic `0xEF53` at offset 56, the block-size formula
`1024 << s_log_block_size` (here 4096), the DYNAMIC revision gate that validates
the offset-84+ fields, and `s_block_group_nr == 0` for a primary superblock. The
`metadata_csum` value at offset 1020 is crc32c (Castagnoli, a different
polynomial from the GPT/zlib CRC32) seeded from the filesystem UUID over the
first 1020 bytes; the fixture documents that method but asserts no value, because
confirming it needs an independent implementation (`dumpe2fs`/`e2fsck`).

## Signed and verified image headers

The [MCUboot fixture](../assets/fixtures/firmware-mcuboot.yaml) is a 32-byte header,
a payload, a protected TLV area (`0x6908`), and an unprotected TLV area
(`0x6907`) holding the SHA-256. The decisive check is coverage: the SHA-256 TLV
hashes the header, the payload, and the protected TLV area in that order, and
excludes the unprotected area that carries the hash and any signatures. A
matching hash is integrity, not authenticity — no signature TLV or key is
present, so the fixture cannot show the image would pass secure boot.

The [UEFI firmware volume fixture](../assets/fixtures/firmware-uefi-fv.yaml) checks
the `_FVH` signature at offset 0x28 and the 16-bit header checksum, which makes
the header, read as little-endian `UINT16` words over exactly `HeaderLength`
bytes, sum to zero. The checksum covers the header only — not the FV body, FFS
files, or contained PE modules, which are parsed at their own layer.

The [ESP32 fixture](../assets/fixtures/firmware-esp32.yaml) checks the `0xE9` magic,
the one-byte XOR checksum (`0xEF` XOR of the segment data bytes, placed as the
last byte of a 16-byte-aligned block), and the appended SHA-256 over the whole
image through the checksum byte. Both are corruption checks, not signatures;
Secure Boot v2 signature blocks would follow the SHA-256 and are absent.

## Using a fixture result

Record the parser or analyzer engine and version, run every case, and compare
the decoded values and validation flags against the `expect`/`expected` block. A fixture
pass establishes the fixture's expected outcomes for that engine; it does not by
itself establish a result on a real image, which has its own digest, coordinate
system, and layering. Keep the fixture check and the target check as separate
outcomes, as the [coverage map](coverage-map.md) requires.
