# Firmware reverse-engineering recipes

Use this reference for vendor update packages, flash dumps, boot components, embedded Linux images, MCU/RTOS binaries, and PC firmware. Start with the requested result, then build only the parsers, disassembler views, capture adapters, or comparison harness needed to establish it. A filesystem tree, a chip-level memory map, and a running service are different results; do not infer one from another.

## Select the smallest path

| Requested result | Start with | Deliver and check |
| --- | --- | --- |
| Identify the image | Hash, header/format probe, bounded strings and entropy windows | Format candidates, device/build claims, exact byte ranges; cross-check headers and lengths |
| Recover a component | Region map, format-specific extractor | Child bytes, parent offset and digest; validate format structure and boundaries |
| Explain boot | Image/partition map, boot metadata, kernel/DTB or reset vector | Boot-stage sequence with addresses and configuration sources; verify each handoff |
| Explain a feature | Rootfs service path or MCU call/interrupt path | Entry point, config, code path, externally visible effect; confirm decisive bytes and runtime behavior when available |
| Explain a UEFI module | Firmware volume parser, GUID/dependency map, PE/COFF analyzer | Module identity, dispatch conditions and protocol uses; verify image bytes and dependency path |
| Analyze an update | Manifest, signature/verification code, slot and rollback metadata | Acceptance and installation path; separate package declarations from enforcement |
| Compare releases | Matched components, normalized filesystem/code diff | Changed component and behavior candidates; prove matching identity and report unmatched regions |
| Observe execution | Suitable board/device or isolated emulator, serial/debug capture | Events within a stated capture window; distinguish modeled peripherals from real hardware |

## Assemble the components

Probe installed tools and versions on the actual host, then choose the few components required by the selected result. Use an existing parser where it supplies validated structure; write a narrow adapter when its output lacks provenance or a vendor format is unsupported.

| Component | Candidate engine or direct implementation | Adapter output |
| --- | --- | --- |
| Region discovery | Binwalk/Unblob plus bounded header reads and entropy windows | Candidate spans with raw offsets, header fields, validation status and overlaps |
| Container/filesystem extraction | Unblob or a format-specific parser; UBI, SquashFS, CPIO, ext and archive tools as appropriate | Child bytes and paths, parent span, extractor diagnostics and hashes |
| Boot metadata | FIT/U-Boot parser, `dtc`/libfdt, UEFI firmware-volume parser, partition parser or vendor header reader | Selected image/configuration, load addresses, boot arguments and referenced partitions |
| Native code | Disassembler/decompiler already available for the target ISA, plus a small address mapper | Functions, calls, strings and memory accesses tied to file offsets and load addresses |
| Update comparison | Component manifest and normalized byte/file/code diff | Matched, changed and unmatched components with identity basis |
| Runtime observation | QEMU with a supported machine, a single-process harness, serial capture or authorized debugger | Timestamped events, machine/peripheral assumptions and capture coverage |

A custom parser should accept immutable bytes and explicit geometry or load-base parameters, reject out-of-range lengths and integer overflow, and return a structured result plus diagnostics. Test it on one known-good fixture and one malformed or truncated fixture. Do not let a scanner's label stand in for parser validation.

## Acquire and identify

Prefer a vendor-supplied image, documented export, or already captured dump. Record source, acquisition method, device model/board revision, firmware version as claimed by the source, byte length, SHA-256, and whether bytes are complete. A partial SPI/NAND dump, update payload, and installed image are not interchangeable. If hardware reads are needed, use authorized access and preserve the original; read protection, debug unlock, flash wear, and bootloader commands can change device state. Treat a serial log or vendor label as a claim until it matches the image.

Probe the outer container before recursive extraction: magic and header fields, endianness, checksums, manifest, architecture hints, partition table, sparse ranges, padding, and high-entropy windows. A scanner such as Binwalk or Unblob can suggest regions; confirm every important hit from raw offsets and a format parser. High entropy alone does not distinguish encryption from compression. Record overlaps, gaps, unknown regions, and whether offsets are file-relative, partition-relative, flash-physical, or load addresses.

For raw flash, determine whether the dump includes NAND out-of-band (OOB) bytes, bad-block markers, ECC, erased blocks, interleaving, or vendor headers before treating offsets as a contiguous logical image. Keep the transformation from physical dump to logical bytes reproducible. Do not silently strip OOB data or bad blocks. For Intel HEX, S-record, UF2, sparse, or vendor records, preserve each record's stated load address and detect overlaps and holes; concatenating records can create a false memory layout.

## Map and unpack the layers

Build a compact region table with `parent digest | offset | length | candidate type | validation | child digest`. Set resource limits for recursion depth, output bytes, file count, and runtime. Extract to an isolated directory; reject absolute paths, `..` traversal, links that escape the tree, special files, and archive bombs. Never mount or execute a candidate during static inspection. Store byte ranges or reproducible extraction commands when a full extracted tree is unnecessary.

Choose the parser from the actual layer: U-Boot/FIT, Android boot or OTA package, GPT/MBR, UBI/UBIFS, JFFS2, SquashFS, ext, CPIO/initramfs, compressed kernel, or vendor-specific framing. Keep compression, signing, encryption, and filesystem layers separate. A valid checksum or successful decompression does not establish authenticity; a signature field does not prove the bootloader checks it. If content is encrypted, report the visible header and verification path rather than claiming to know plaintext. Cross-check extracted sizes, internal checksums where applicable, superblocks, directory structure, and referenced partitions. UBI volumes and raw MTD eraseblocks require their own geometry and volume mapping; they are not ordinary block filesystems.

## Reconstruct the boot and trust path

For an embedded Linux target, trace ROM/first-stage loader when documented, bootloader, boot image, kernel, device tree, initramfs/rootfs, init system, and application service. Use boot arguments, FIT configuration, DTB `/chosen` and `compatible`, partition labels, root filesystem references, init scripts, and service units to connect stages. A DTB describes intended hardware and configuration; it does not prove the connected board matches it. Keep bootloader environment and overlay/config partitions distinct from immutable image contents.

For secure boot or update questions, identify the signed object, signature scope, public-key anchor, hash algorithm, verifier code path, policy flags, board/version checks, anti-rollback state, A/B slot selection, and failure behavior. Distinguish `present in package`, `checked by code`, and `observed on device`. Do not claim an update is accepted, rejected, or bypassable from metadata alone. If a check depends on OTP/eFuse/TPM or server state unavailable in the artifact, name that dependency.

## Explain embedded Linux behavior

Start from the externally relevant service or task. Map boot-time startup to executable and configuration: init scripts/service units, symlinks, overlays, environment, command-line arguments, sockets/listeners, web routes, RPC handlers, credentials/config storage, IPC, and update helpers. Resolve symlinks and architecture before choosing a native analyzer. Link string matches to callers and dispatch paths; a string or port in a binary does not prove that path runs. For remote fingerprintability, tie a proposed signal to a reachable listener, request preconditions, response or timing, and a repeatable control across versions or configurations. Prefer an authorized capture or controlled probe; state when the claim is only a static hypothesis.

When reporting components or known issues, identify the actual shipped version and any vendor patches or backports. A package name or version string alone is insufficient to establish that a particular defect is present. Separate exposure, reachability, and exploitability.

## Explain MCU and RTOS behavior

For a raw binary, infer architecture, endianness, instruction mode, memory map, load base, and entry points from mutually consistent evidence: vector table/reset handler, image headers, vendor linker/map files, interrupt tables, branch targets, literal pools, and known peripheral address ranges. For Cortex-M, the initial stack pointer and reset vector are strong starting clues, subject to image offset and remapping. Keep file offsets, flash addresses, and RAM addresses distinct. Test the chosen base by checking multiple code/data references and plausible control flow, not one disassembled instruction.

Trace startup through clock/memory initialization, interrupt registration, scheduler/task creation, callbacks, protocol parsers, and update/bootloader transitions. Model memory-mapped I/O as hardware interactions, not ordinary variables. Identify task context and ISR context before claiming call order. For vendor SDK or RTOS identification, use multiple structural features; library signatures and strings can be misleading after link-time optimization or stripping. Use [native binary analysis](native-and-artifacts.md) for functions and [protocol analysis](process-and-reconstruction.md) for observed device traffic.

## Inspect PC firmware and UEFI

For a UEFI capsule or SPI image, map flash descriptor/regions when present, firmware volumes, firmware files and sections, NVRAM stores, and embedded PE/COFF modules. Keep capsule payload offsets distinct from installed flash offsets. Identify module GUID, UI name, architecture, compression section, and dependency expression before analyzing code. Follow the relevant SEC/PEI/DXE handoff or UEFI boot/runtime interface; a module's presence does not prove it dispatches in the selected boot mode. Use a firmware-volume parser and PE analyzer for static work. Hardware-facing tools such as CHIPSEC belong only in an authorized device workflow because they can require privileged hardware access.

For update or integrity questions, trace capsule acceptance, firmware-management policy, authenticated variable handling, signed regions, and any measured-boot claims separately. A signature or measurement field found in the image does not establish the platform's enforcement state. Compare firmware volumes by GUID and image digest, not only by textual module names.

## Execute only when the result requires it

Static extraction should not launch firmware. When runtime evidence matters, select the lightest adequate method: existing logs, isolated user-mode execution of one binary, system emulation with a supported board, a peripheral-aware harness, or authorized hardware observation. QEMU loading bytes is not the same as emulating the actual board; CPU, memory layout, flash, interrupts, peripherals, and boot ROM behavior must match the claim being tested. Record emulator version, machine model, loaded ranges, stubs, network exposure, and capture window. Keep emulated networks isolated unless the requested test requires a defined connection.

For physical devices, prefer passive serial/network capture before invasive debug access. Record board revision, probe attachment, power cycle, reset state, and whether instrumentation can perturb timing. Keep writes, flashing, debug unlock, bootloader environment changes, and fault injection separate from read-only analysis and require appropriate authorization. A single boot trace supports only the observed configuration and window.

## Verification and output

Validate the narrowest result that matters: parser offsets round-trip to raw bytes; extracted child digests are stable; a boot-stage reference points to the correct image; a service path reaches its actual entry point; a claimed update check has a corresponding verifier branch; a runtime event repeats under the same conditions. For version comparisons, pair like-for-like components using digest, build ID, partition role, and architecture; report changed packaging separately from changed code. If a component cannot be extracted or matched, preserve it as an explicit unknown.

The answer should give the requested finding first, then the exact supporting offsets, addresses, paths, or capture events. Include target digest, acquisition completeness, key tool versions, and material uncertainty. Optional graphs and evidence bundles follow [the shared conventions](evidence-and-runtime.md) only when cross-layer joins or auditability warrant them.

## Format and engine references

- [Unblob extraction and report behavior](https://github.com/onekey-sec/unblob/blob/main/README.md)
- [Linux UBI/UBIFS layering](https://docs.kernel.org/filesystems/ubifs.html)
- [U-Boot FIT image format](https://docs.u-boot.org/en/stable/usage/fit/index.html) and [verified boot](https://docs.u-boot.org/en/latest/usage/fit/verified-boot.html)
- [Linux devicetree usage](https://docs.kernel.org/devicetree/usage-model.html)
- [Device Tree Compiler and libfdt](https://github.com/dgibson/dtc)
- [UEFI Platform Initialization phases](https://uefi.org/specs/PI/1.8/V1_Overview.html), [firmware updates](https://uefi.org/specs/UEFI/2.11/23_Firmware_Update_and_Reporting.html), and [CHIPSEC](https://github.com/chipsec/chipsec)
- [QEMU generic loader](https://www.qemu.org/docs/master/system/generic-loader.html) and [system emulation](https://www.qemu.org/docs/master/system/index.html)
