# Firmware fixtures

These synthetic fixtures give firmware parsers and base-inference logic a known
input with a known answer, so a result can be checked against bytes rather than
trusted from a scanner label. They parallel the [Rust](../assets/fixtures/rust-patterns.yaml)
and [environment](environment-fixtures.md) fixtures: the fixture is checkable on
its own, while assessing a real tool additionally requires that tool's version,
settings, and output against the actual target. Each fixture is pure data with
no code to execute. See [firmware structure](firmware.md) and the
[firmware lab](firmware-lab.md) for the methods these support.

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

## Using a fixture result

Record the parser or analyzer engine and version, run every case, and compare
the decoded values and validation flags against the `expect` block. A fixture
pass establishes the fixture's expected outcomes for that engine; it does not by
itself establish a result on a real image, which has its own digest, coordinate
system, and layering. Keep the fixture check and the target check as separate
outcomes, as the [coverage map](coverage-map.md) requires.
