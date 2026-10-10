# Firmware and hardware specializations

These methods extend [firmware structure](firmware.md) and [firmware lab work](firmware-lab.md). Template: [hardware scope](../assets/templates/hardware-scope.yaml). They depend on exact hardware, format or vendor support; a documented route can still yield a precise unavailable result.

## Registers, RTOS state, and trust boundaries

[CMSIS-SVD parsers](https://github.com/cmsis-svd/cmsis-svd) can turn compatible device descriptions into register/field records. Bind the SVD to the actual part/revision and retain the source digest. Check base addresses, arrays, inherited definitions, access widths, reset values, read actions and write semantics. Imported names are hardware-description claims until checked against the device manual or observed accesses. Importing labels into a database does not authorize reading or writing registers.

RTOS analysis uses memory maps, symbols/debug types when available, scheduler/interrupt code, task stacks and queue/timer structures. Identify the implementation and configuration before applying FreeRTOS, Zephyr, ThreadX or vendor-specific structure layouts. Check a task candidate through entry address, stack bounds and scheduler references; a string resembling a task name is insufficient. Live task snapshots can race with scheduling.

For secure/nonsecure firmware, trusted applications or hypervisor transitions, map each image, execution privilege, entry/exit mechanism, shared-memory contract and verification stage. Keep image signatures, measurement records and observed enforcement separate. A read-only image review can establish verifier code and configured policy without establishing fuse state or runtime enforcement.

## Flash filesystems and platform tables

| Tool family | Use | Checks |
| --- | --- | --- |
| Linux MTD utilities, including nanddump when supported | Acquire logical/raw NAND through the actual controller interface | Record controller ECC/OOB behavior, bad-block handling, geometry and whether the tool returns corrected or raw data. |
| [UBI Reader](https://github.com/onekey-sec/ubi_reader) | Inspect and extract compatible UBI/UBIFS images | Preserve physical erase blocks, logical volume mapping, generation information and unavailable journal state. |
| [Jefferson](https://github.com/sviehb/jefferson) | Extract supported JFFS2 images | Record node/checksum errors and unresolved versions; recovered files may reflect only part of the filesystem history. |
| UEFITool/UEFIExtract and CHIPSEC | Decode firmware volumes/capsules or inspect supported platform state | Distinguish static file parsing from privileged hardware queries and changes. |
| [ACPICA](https://github.com/open-acpica/acpica) tools such as iasl/acpidump | Acquire or decode compatible ACPI tables and AML | Bind all referenced tables and namespace context; decompilation may need external declarations. Firmware-table evaluation can have effects. |

Apply [firmware extraction](firmware.md) coordinate, provenance and completeness rules. Correctly extracted bytes are not proof that those bytes are selected at boot. Compare active slots, variables, manifests and actual boot observations where available.

## USB, Bluetooth, and radio captures

[USBPcap](https://github.com/desowin/usbpcap) supplies Windows USB capture; Linux usbmon and supported hardware analyzers provide other views. Record the bus/controller, device enumeration, configuration, interface, alternate setting, endpoint, transfer type and capture level. An OS URB capture differs from electrical bus traffic. Reassemble transactions with direction/status and preserve incomplete transfers.

For Bluetooth, use compatible host-controller logs, BlueZ btmon or an appropriate radio capture. Bind connection identity, address changes, service/characteristic discovery, negotiation and capture location. HCI observations do not automatically expose encrypted over-the-air payloads or every controller-internal event. Firmware callbacks and ATT/GATT records need explicit identity/time joins.

For RF work, [GNU Radio](https://www.gnuradio.org/about/) and [inspectrum](https://github.com/miek/inspectrum) can assist with supported captured sample formats and signal inspection. Record sample rate, center frequency, complex-sample format, gain, clock/timing and filtering. Progress from samples to symbols to frames with independent known transmissions or fixtures. A plausible demodulation is a hypothesis until framing/checksums and repeated captures support it. Passive capture and active transmission are different experiments.

**Deliverable:** original capture, device/interface context, decoding parameters, transaction/frame records, firmware-code associations where supported, and capture-layer limitations. [Protocol methods](protocol-and-data-formats.md) cover message semantics.

## Hardware execution trace

Identify the actual trace source, packet architecture, transport, sink, clock and capture interface. [CoreSight](https://docs.kernel.org/trace/coresight/coresight.html) systems can route supported processor or instrumentation trace to an available sink; hardware and firmware configuration determine which paths exist. [OpenCSD](https://github.com/Linaro/OpenCSD) decodes supported packet streams. Bind decoder support to the exact protocol/version and distinguish instruction-path reconstruction from software instrumentation payloads.

Preserve raw trace, trace IDs, configuration, synchronization points, loss/overflow reports and the code images required for reconstruction. An ETM instruction stream and ITM/SWO instrumentation have different evidence coverage. Check a known branch or emitted marker, then correlate decoded locations with the correct load map and execution context. Missing packets or code bytes break reconstruction; retain gaps instead of joining across them. Multicore trace needs context IDs and synchronized time before asserting cross-core order.

**Deliverable:** decoded supported events/ranges, raw-packet references, matched code/configuration and explicit trace gaps. A probe connected over SWD/JTAG does not establish an available instruction-trace path.

## FPGA, HDL, and programmable controllers

[Yosys](https://github.com/YosysHQ/yosys) and a compatible simulation flow such as [Verilator](https://verilator.org/guide/latest/overview.html) can analyze or exercise available HDL/netlists. Verilator compiles supported HDL into a model that can be built and run for simulation. These tools do not by themselves recover arbitrary vendor bitstreams into original HDL. Bitstream analysis needs device-family documentation or a verified family-specific decoder, with encrypted or unsupported regions explicit.

For a recovered netlist, retain pin, clock, reset, memory and I/O mappings. Check one bounded behavior in simulation against an independent waveform or hardware observation. Timing, routing and analog effects can exceed the model. A synthesized equivalent need not recover original module boundaries or names.

For PLC/industrial controllers, identify the vendor/project/block format and execution model: ladder, structured text, function blocks, generated native code, or proprietary bytecode. Preserve task scheduling, scan cycles, retained variables, I/O maps and versioned libraries. Use compatible vendor exports or documented parsers where available; otherwise apply the [custom VM method](virtual-machines.md) to a bounded subset. An offline reconstruction does not authorize downloading code or changing controller state.

## Side-channel and fault-observation experiments

[ChipWhisperer](https://github.com/newaetech/chipwhisperer) is a candidate for supported measurement hardware and controlled laboratory experiments. Define the question, instrument/target connection, stimulus, trigger, baseline, repeat count and measured outcome. Keep power/EM observations and injected faults distinct. Reproducibility needs instrument calibration, firmware identity, reset state and a controlled environment.

Report measured differences and uncertainty, including alignment choices and failed/no-effect trials. A trace correlation is not automatically a recovered secret or proof of a code path. Device-specific fault parameters and effects require a separate authorized experiment; no generic setting is valid for every board. This route documents experiment and result requirements without claiming universal hardware support.
