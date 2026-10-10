# Firmware execution, acquisition, and signals

This guide covers repeatable experiments with firmware, physical memory acquisition, and captured hardware transactions. Image structure, boot chains, filesystems, and update analysis are covered in [Firmware](firmware.md). Experiments use the matching [templates](templates.md) only where they help reproduce a result.

## Engine selection

| Engine | Useful role | Selection conditions and limits |
| --- | --- | --- |
| [Renode](https://renode.readthedocs.io/en/latest/) | Execute embedded software with CPU, memory, interrupt, and peripheral models; script input and observations | A compatible CPU is only one dependency. Check the exact platform description, peripheral behavior, firmware loading, and supported test interface. |
| [Qiling](https://github.com/qilingframework/qiling) | Instrument selected executables or functions with an emulated loader, OS services, and filesystem | Check architecture, ABI, loader, syscall/API coverage, and root filesystem. A userspace experiment does not reproduce the original kernel or board. |
| [flashrom](https://github.com/flashrom/flashrom) | Detect and read supported flash chips through a supported programmer | Match chip, programmer, voltage, connection, and address coverage. This is not a universal raw NAND acquisition tool. |
| [pyOCD](https://pyocd.io/) | Inspect supported Arm microcontrollers through debug probes; access memory, registers, and supported trace interfaces | Record probe UID, target part, device pack, connection mode, and halt/reset effects. A register read can have a hardware side effect. |
| [sigrok](https://sigrok.org/wiki/Main_Page), including PulseView and sigrok-cli | Acquire supported instrument data and decode digital signals | Match hardware, sample rate, thresholds, channel mapping, decoder options, and capture duration. PulseView is an interactive frontend; sigrok-cli supports repeatable command-line work. |
| [cantools](https://github.com/cantools/cantools) | Decode and encode CAN messages using supported database formats, including DBC | A database is an interpretation supplied with the capture. Its names, scaling, multiplexing, and frame IDs need checking against observed bytes and device state. |

These are alternative components for selected results. The exact installation and one representative input establish usable support. [Renode's platform catalogue](https://renode.readthedocs.io/en/latest/introduction/supported-boards.html) gives starting points; a platform description may need additional hardware models.

## Repeatable firmware execution

Template: [firmware experiment](../assets/templates/firmware-experiment.yaml).

1. **Define the observation.** Examples include a command's reply, a peripheral write sequence, a boot-stage transition, or the parser's return value. Choose an observation that can be compared with a device capture or known fixture.
2. **Bind the bytes and environment.** Record image digests, architecture/instruction mode, endianness, entry point, loaded ranges, stack, ABI, and expected initial state. Identify ROM routines, external libraries, files, NVRAM, clocks, interrupts, DMA, and memory-mapped I/O needed by the selected path.
3. **Choose execution scope.** Use a board model for interrupt/peripheral interactions, an OS-aware emulator for a compatible executable, or a bounded function harness when its calling convention and dependencies are known.
4. **Describe substitutions.** Each stub records the address/API, returned values, state transitions, and evidence for those choices. An input-independent constant supplied for a hardware register is a hypothesis. Findings downstream of it retain that qualification.
5. **Bound the experiment.** Define instruction/time/event limits, a completion condition, and the network/filesystem exposure. A snapshot is useful only if it also restores relevant peripheral, timer, file, and external state.
6. **Compare runs.** Run a known input twice from the same state. Compare selected outputs and explain variation. For a hardware claim, compare against a device trace and document differences in timing or modeled behavior.

For Renode, the reusable unit is the platform description plus a monitor/test script and firmware digests. Preserve the selected memory-loading command, peripheral wiring, virtual-time settings, and observation interface. Vendor demo scripts can contain downloads or setup commands; inspect those dependencies before adapting them. A machine reaching its main loop does not establish coverage of every peripheral.

For Qiling, preserve the rootfs/library digests, binary arguments, emulated environment, hooks, mapped files, and stopping condition. Hooks that replace OS functions can change error behavior. Record unsupported calls and accesses instead of converting them into unexplained success. The [Qiling documentation](https://docs.qiling.io/en/latest/) and installed examples define the API for that version.

**Deliverable:** an experiment specification, the minimal platform/harness files, input/output captures, repeatability result, and a list of dependencies still modeled or unavailable.

## Flash and debug acquisition

Template: [acquisition record](../assets/templates/acquisition.yaml).

The acquisition record distinguishes chip reads, debug memory reads, filesystem copies, and vendor update files. They can contain different bytes even for the same product release.

1. Identify board revision, chip markings, expected capacity, interface, voltage, power source, and bus ownership. Check supported programmer/target entries before connecting. In-circuit reads can be affected by another bus master or back-powering.
2. Record the exact connection and tool options. For flashrom, distinguish the external programmer from an internal platform access path. For pyOCD, select the probe and target explicitly; record the device pack and connection sequence.
3. Read only the intended region into a new file. Record halt, reset, watchdog, protection, or access-denied behavior. A debug unlock operation that erases flash is a different operation from acquisition.
4. Repeat the read where feasible. Compare complete digests and differing byte ranges. Stable repeated bytes support acquisition consistency; they do not establish that the selected address space contains the whole device.
5. Check expected size, vector/header locations, erased ranges, aliases, and declared protection gaps. Preserve original dumps before transformations.

Raw NAND needs separate page/OOB geometry, ECC, bad-block, and controller handling as described in [Firmware](firmware.md). A CPU's mapped flash window may omit spare bytes or remap bad blocks. Debug access to a peripheral window can clear status or pop FIFO data; ordinary RAM/flash ranges and side-effectful registers require different acquisition plans. [pyOCD's command reference](https://pyocd.io/docs/command_reference.html) documents memory operations for the selected version.

**Deliverable:** original read files, target/connection record, per-read digests, byte-range disagreement report, and a completeness statement. Flash programming or restoration requires its own explicit operation and readback procedure.

## Signal and bus analysis

Template: [bus decoding](../assets/templates/bus-decoding.yaml).

Preserve the raw capture alongside decoded transactions. The interpretation includes channel-to-pin mapping, sample rate, thresholds, clock polarity/phase, bit order, framing, and decoder version. Sample rate must resolve the shortest relevant transitions; a decoder returning plausible text is insufficient validation.

For UART/SPI/I2C or another supported sigrok decoder, inspect several decoded transactions against the underlying edges. Record dropped samples, incomplete transactions, contention, and timing resolution. Correlate events with a known device action and code locations only when the time base and target identity support the join. Passive acquisition and actively generated traffic are separate procedures.

For CAN, record standard/extended identifiers, CAN/CAN FD flags, payload length, timestamps, and channel. Preserve the database digest and message/signal selection. Validate endianness, signedness, scaling, multiplexors, counters, and checksums against known states. An encode/decode round trip checks database consistency; comparison with an independently understood frame checks the interpretation. A missing frame may reflect filtering or capture loss.

**Deliverable:** raw capture, decoding configuration, transaction table with source sample/packet references, field hypotheses, known-state comparisons, and unresolved electrical or protocol assumptions.

## Small combined experiment

To explain how an MCU handles a sensor response: identify the relevant image and handler -> capture one known sensor transaction -> map buffer and register references -> model only the peripheral behavior needed by that handler -> replay the captured response -> compare the resulting writes/return value with the observed device state. A failing comparison identifies either a wrong code interpretation, an incomplete capture, or a missing environmental dependency.
