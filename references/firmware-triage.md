# Firmware triage

Triage turns an unidentified blob into a region map, an architecture claim, and a load-address claim that later analysis can rely on. It precedes the method selection in [Firmware](firmware.md) and produces the inputs that [embedded Linux service analysis](embedded-linux-services.md), MCU/RTOS analysis, and update analysis consume. Template: [firmware triage record](../assets/templates/firmware-triage.yaml). Fixtures: [firmware fixtures](firmware-fixtures.md) supply a uImage header and a Cortex-M vector table with known answers for the parser and load-base checks below.

Each step ends with a check that could show the step's result to be wrong. A step whose check cannot be run leaves its result marked as a candidate.

## Order of operations

1. **Bind the bytes.** Record path, byte length, SHA-256, source, acquisition method, and whether the bytes are a vendor package, an installed image, a chip read, or a debug memory read. These are different objects even for one product release.
2. **Read the outer container before scanning.** Check the first 64 bytes, the last 64 bytes, and any header the vendor documents. A container header gives sizes, offsets, checksums, and architecture claims that constrain every later step. Scanning first produces hits inside compressed or encrypted spans that cannot be interpreted without the container.
3. **Scan for embedded signatures with bounded reads.** Binwalk or Unblob locate candidates; a candidate becomes a region only after its parser validates the header, length, and, where available, checksum against the raw bytes. Record overlaps and gaps.
4. **Measure entropy in fixed windows.** A window at or near 8 bits per byte is compressed, encrypted, or random. Entropy does not distinguish these. A compressed span has a parseable header and decompresses to lower-entropy bytes; an encrypted span has neither. A span of 0x00 or 0xFF is padding or erased flash.
5. **Identify the architecture** of each native-code region from mutually consistent evidence, listed below.
6. **Determine the load base** of each raw code region from mutually consistent evidence, listed below.
7. **Choose the next method.** A filesystem goes to [embedded Linux services](embedded-linux-services.md); raw MCU code goes to the MCU/RTOS section of [Firmware](firmware.md); firmware volumes go to the UEFI section; update containers go to the update sections.

## Container and filesystem signatures

Offsets are from the start of the structure. "Weak" means the signature alone produces false positives; the parser check is mandatory. A listed value is a starting hypothesis to confirm against the format's own documentation, not a substitute for it.

| Family | Signature | Offset | Parser check |
| --- | --- | --- | --- |
| U-Boot legacy image (uImage) | `27 05 19 56` | 0 | 64-byte header; header CRC32 with the CRC field zeroed; data CRC32 over `size` bytes; OS/arch/type/compression enums; load and entry addresses |
| Flattened device tree, FIT image | `D0 0D FE ED` | 0 | `totalsize`, struct/strings offsets inside the blob; `dtc -I dtb -O dts` or libfdt walk; FIT `/images` and `/configurations` nodes with hashes and signatures |
| Android boot image | `ANDROID!` | 0 | Header version selects layout; page size; kernel/ramdisk/dtb sizes fit the file; `VNDRBOOT` marks a vendor boot image |
| Android sparse image | `ED 26 FF 3A` | 0 | Chunk headers (raw, fill, don't-care, CRC) sum to the declared total blocks |
| Android OTA payload | `CrAU` | 0 | Version 2 manifest; partition operations with source/destination extents; signatures are a separate claim |
| Android verified boot metadata | `AVB0` | 0 | Descriptor table, hash/hashtree descriptors, public key; `AVBf` footer at the end of a partition |
| Android logical partition metadata | `gDla` geometry then `0PLA` headers | 4096 in `super` | Geometry size, metadata slot count, per-slot partition and extent tables |
| ELF | `7F 45 4C 46` | 0 | Class, data encoding, `e_machine`, program headers within the file |
| PE/COFF | `MZ` then `PE\0\0` at `e_lfanew` | 0 | Machine, section table, optional header size; UEFI modules are PE32/PE32+ or TE |
| UEFI firmware volume | `_FVH` | 0x28 | Volume length, block map, file headers with checksums and GUIDs; UEFITool/UEFIExtract report |
| Intel SPI flash descriptor | `5A A5 F0 0F` | 0x10 | Region table (descriptor, BIOS, ME/CSME, GbE, platform data) with base/limit; region offsets apply to the whole chip image |
| Terse Executable (TE) | `VZ` | 0 | Stripped PE for PEI; the header strips a fixed offset that affects address translation |
| SquashFS | `hsqs` little-endian, `sqsh` big-endian; older variants `shsq`, `qshs`, `tqsh`, `hsqt` | 0 | Superblock version, compression ID, bytes used, inode/directory table offsets inside the span; vendor LZMA variants need matching extractors |
| CramFS | `45 3D CD 28` little-endian and `Compressed ROMFS` at 16 | 0 | Size, CRC over the image with the CRC field zeroed |
| JFFS2 | `85 19` little-endian or `19 85` big-endian at each node | node start | Node type, total length, header CRC, node CRC; nodes repeat across the span; erase-block alignment; obsolete node versions |
| UBI | `UBI#` at each erase block | PEB start | EC header CRC, VID header `UBI!` at the VID offset, volume table; geometry (PEB size) must be known or inferred from the `UBI#` spacing |
| UBIFS | `31 18 10 06` little-endian | superblock node in volume | Lives inside a UBI volume; superblock geometry (LEB size, min I/O) and master nodes |
| YAFFS2 | none | — | Object headers in chunk+spare layout; chunk and spare sizes must be recovered; an unscrubbed dump includes OOB |
| ext2/3/4 | `53 EF` | 0x438 | Superblock block size, block count, feature flags, group descriptors inside the span |
| F2FS | `10 20 F5 F2` | 0x400 | Superblock checksum and segment layout |
| romfs | `-rom1fs-` | 0 | Full size and volume checksum |
| CPIO newc / crc | `070701` / `070702` | 0 | Each header's name size and file size; `TRAILER!!!` final entry; commonly inside gzip/xz |
| tar | `ustar` | 257 | Header checksum per entry |
| ZIP | `PK 03 04` local header, `PK 05 06` end of central directory | 0 / near end | Central directory offsets fit; nested APK, JAR, DFU packages, and vendor update zips reuse it |
| gzip | `1F 8B` | 0 | Member header flags; trailing CRC32 and ISIZE; concatenated members are legal |
| xz | `FD 37 7A 58 5A 00` | 0 | Stream header check type; index and footer; `xz -l` reports blocks |
| bzip2 | `BZh` | 0 | Block magic `31 41 59 26 53 59` after the header |
| zstd | `28 B5 2F FD` | 0 | Frame header; skippable frames `5x 2A 4D 18` |
| LZ4 frame | `04 22 4D 18` | 0 | Frame descriptor flags and block checksums |
| lzop | `89 4C 5A 4F 00 0D 0A 1A 0A` | 0 | Header checksum; block checksums |
| LZMA alone | `5D` then 4-byte dictionary size, then 8-byte uncompressed size (weak) | 0 | Properties byte decodes to valid lc/lp/pb; declared size or `FF..FF` end marker; decompression must succeed within a limit |
| 7-Zip | `37 7A BC AF 27 1C` | 0 | Start header CRC; next-header offset inside the file |
| ARM Linux zImage | `18 28 6F 01` | 0x24 | Start and end fields at 0x28 and 0x2C; an appended DTB may follow the end |
| ARM64 Linux Image | `ARM\x64` | 0x38 | Text offset and image size fields at 8 and 16 |
| x86 bzImage | `HdrS` | 0x202 | Boot protocol version, setup sectors, payload offset |
| RISC-V Linux Image | `RISCV` | 0x38 | Text offset and image size fields at 8 and 16 |
| U-Boot environment | 4-byte CRC32 then `NAME=value\0` pairs, double NUL end | partition start | CRC over the remainder of the environment size; redundant environments add a flags byte at 4 |
| MCUboot image | `3D B8 F3 96` | 0 | Header size, image size, flags, version; TLV area with hashes/signatures after the image |
| UF2 | `UF2\n` and `57 51 5D 9E` | 0 and 4 of each 512-byte block | Block count, target address, family ID per block; blocks may be non-contiguous |
| Intel HEX | ASCII `:` records | line start | Record checksum; record types 00–05; extended addresses define holes and overlaps |
| Motorola S-record | ASCII `S0`–`S9` records | line start | Record checksum and address width; S7/S8/S9 give the entry point |
| TI-TXT | ASCII `@addr` sections, `q` end | line start | Address lines and hexadecimal byte lines |
| DFU suffix | ASCII `UFD` | 8 bytes before end | Suffix length, vendor/product IDs, CRC32 over the file excluding the CRC |
| ESP32 application image | `E9` | 0 | Segment count, entry address, segment headers with load addresses, optional SHA-256 trailer |
| Broadcom TRX | `HDR0` | 0 | Length, CRC32 over the image after the CRC field, up to three partition offsets |
| Netgear `.chk` | `*#$^` | 0 | Header length, board ID string, kernel and rootfs sizes and checksums |
| Sercomm | `sErCoMm` | 0 | Vendor header with product and version fields; multiple copies may exist |
| D-Link SEAMA | `5E A3 A4 17` | 0 | Metadata size, image size, MD5 of the image |
| D-Link SHRS | `SHRS` | 0 | Encrypted container with plaintext length fields; contents need the vendor key |
| TP-Link, Realtek, MediaTek, and other vendor headers | vendor string in the first 0x200 bytes | 0 | Vendor documentation or a confirmed community parser; sizes and checksums must match the file |
| PEM / DER objects | `-----BEGIN`, `30 82` | anywhere | ASN.1 structure parses; presence shows a key or certificate exists, not that code uses it |

A high-entropy span with no signature and no parseable header is unknown, not encrypted. Record it as unknown with its range.

## Architecture identification

Use at least two independent signals. A single signal is a hypothesis.

| Signal | Reading | Check |
| --- | --- | --- |
| Container claim | uImage `arch`, FIT `arch` property, ELF `e_machine`, PE `Machine`, DTB `compatible`, vendor header | A claim only; confirm against code bytes |
| Contained ELF files | `readelf -h` on any extracted executable | The rootfs architecture need not match a bootloader or coprocessor image in the same package |
| Strings | Toolchain banners (`GCC: (GNU)` with target triple), kernel version lines with `-mips`, `-arm`, `aarch64`, SDK names, vendor SoC names | Strings can come from an unrelated embedded blob |
| Function prologues | ARM: `xx xx 2D E9` (`STMFD sp!`); Thumb: `xx B5` (`PUSH {.., lr}`); AArch64: `FD 7B xx A9` (`STP x29, x30`) and `C0 03 5F D6` (`RET`); MIPS: `27 BD FF xx` big-endian or `xx FF BD 27` little-endian (`ADDIU sp, sp, -n`); PowerPC: `94 21 FF xx` (`STWU r1`); x86: `55 89 E5` or `55 48 89 E5`; RISC-V: `13 01 01 FF` (`ADDI sp, sp, -16`) or compressed `41 11`; Xtensa: `36 41 00` (`ENTRY`) | Count occurrences at 2- or 4-byte alignment across the region; a correct guess produces hundreds of aligned hits, a wrong one produces scattered hits |
| Statistical classifiers | Binwalk `-A` opcode signatures, cpu_rec, ISAdetect | Report the classifier, version, and window; treat as one vote |
| Endianness | Literal addresses, lengths, and table entries read consistently in one byte order; MIPS and PowerPC ship in both | A mixed reading (lengths plausible in one order, pointers in the other) means a wrong region boundary or a multi-image file |
| Disassembly sanity | Disassemble a 4 KB window with the candidate ISA: branch targets land on prologues, literal pools sit between functions, no long runs of invalid or implausible instructions | Run on two windows far apart; one window can coincide with data |

Record the chosen ISA, variant (ARMv7-M, MIPS32r2, etc.), endianness, and instruction mode with the signals that support it.

## Load-address determination for raw code

A raw region has file offsets. Code refers to load addresses. The mapping is a hypothesis until several independent references agree.

| Method | Procedure | Falsification |
| --- | --- | --- |
| Container field | uImage/FIT `load` and `entry`, ESP32 segment addresses, Intel HEX/S-record/UF2 record addresses, MCUboot header | A packaging claim; still check one reference |
| Vendor memory map | SoC reference manual flash base (for example `0x08000000` on many Cortex-M parts, `0x00000000` on others), SVD device memory, linker map if available | The bootloader may run from a different base than the application; a remapped vector table changes the mapping |
| Cortex-M vector table | Entry 0 is the initial stack pointer inside SRAM; entries 1 onward are handler addresses with bit 0 set (Thumb); reserved entries are zero; handler addresses fall inside the image | Choose the base that places every non-zero handler inside the region; a base that places any handler outside the region, at an even address, or inside the vector table is wrong |
| ARM/AArch32 reset vector | Entry at 0 is a branch or `LDR pc, [pc, #n]`; the loaded value is the handler address | Decoded target must land on a prologue |
| MIPS reset | Boot code at the reset exception address; `LUI`/`ORI` or `LUI`/`ADDIU` pairs build absolute addresses that must fall in the region or in known peripheral space | Several reconstructed addresses outside the region or peripheral space mean a wrong base |
| String pointer scan | Collect offsets of null-terminated strings; collect 4-byte aligned words in the image; for each candidate base, count words equal to `base + string_offset`; rbasefind and similar scripts automate this | The correct base has a sharp peak; a flat histogram means stripped pointers, position-independent code, or a wrong ISA/endianness |
| Jump and literal pools | Thumb literal pools, switch tables, and function pointer tables yield addresses that must land on instruction boundaries inside the region | Entries landing mid-instruction or outside the region |
| Decompiler cross-references | Load the region at the candidate base and count resolved references to strings and functions; compare with one alternative base | A correct base resolves far more references than its neighbors |

Report the base with the methods that agree, the alternatives rejected, and any region (RAM data, remapped vectors, overlays) that uses a different mapping. Keep file offset, flash address, and RAM address as separate columns in every later record.

## Layer decision

| Observation | Next layer |
| --- | --- |
| Validated filesystem span | Extract into an isolated directory; proceed with [embedded Linux services](embedded-linux-services.md) |
| Compressed span with a kernel signature inside | Decompress to a separate file with its own coordinates; a kernel image contains an appended DTB, initramfs, or version string |
| Raw code with a vector table, no filesystem, no OS strings | MCU/RTOS path in [Firmware](firmware.md); bind the base first |
| RTOS strings (FreeRTOS, Zephyr, ThreadX, VxWorks, Nucleus, RTX, uC/OS) | RTOS identification and task structures in [Firmware specializations](firmware-specializations.md) |
| `_FVH` volumes or a flash descriptor | UEFI section in [Firmware](firmware.md) |
| Update manifest, signature block, slot metadata | Update sections in [Firmware](firmware.md); template [update policy](../assets/templates/update-policy.yaml) |
| Raw NAND with OOB spacing | Geometry recovery in [Firmware lab](firmware-lab.md) before any of the above |
| Multiple architectures in one package | Separate images for the application processor, radio or baseband, security coprocessor, and microcontrollers; map each separately and record which boots first |
| No parseable structure anywhere | Report the hash, entropy profile, and the vendor's documented encryption or packaging, and stop; do not infer plaintext |

## Common wrong conclusions

| Claim | Why it fails | Replacement |
| --- | --- | --- |
| "Binwalk found a SquashFS at offset X" means a SquashFS exists at X | Signature hits occur inside compressed data, previous images, and update scripts | A SquashFS exists at X when its superblock parses and its tables fit inside the span |
| "The image is encrypted" from entropy | Compression and encryption both score near 8 bits per byte | Encrypted means no parseable header and vendor documentation or code that decrypts it |
| "The file is ARM" from one string | Strings travel with libraries and vendor SDKs | Two independent signals from the code bytes |
| "The base is 0x08000000" because that is common | Boards and bootloaders differ; applications live after a bootloader | Vector table consistency plus a pointer scan |
| "The kernel is version X" from a version string | Vendors backport; the string names a tree, not a patch state | Shipped configuration, build date, and function-level comparison for any defect claim |
| "The rootfs is the running system" | A/B slots, overlays, and configuration partitions change what runs | Boot selection from the bootloader environment and mounted overlay order |
| "This offset in the file is this address on the device" | Container headers, sparse holes, OOB bytes, and partition tables shift every layer | A coordinate column per layer with the transformation recorded |

## Deliverable

A region map in the [firmware triage record](../assets/templates/firmware-triage.yaml) with: image identity, one row per validated region and per unknown span, architecture and endianness per code region with supporting signals, load base per raw code region with the agreeing methods, parser and scanner versions, and the next method selected for each region. The map is the first entry in the finding's evidence table.
