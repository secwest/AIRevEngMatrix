# Analysis templates

Templates are working records and starting specifications for a selected analysis. Copy the relevant files from `assets/templates/` into the investigation workspace, bind them to the actual target, and retain the completed record beside the result. A simple one-command investigation may need only a short finding.

The YAML records are documentation formats. No runner automatically interprets them, installs engines, or executes their command fields. An adapter can consume a selected subset after validating its types and required fields. `framed-record.ksy` is the one engine-native template: a complete synthetic Kaitai Struct schema.

## Selection

| Template | Use | Method |
| --- | --- | --- |
| [Toolkit plan](../assets/templates/toolkit-plan.yaml) | Select minimal components, bind inputs, and define checks | [Assembly](assembly-patterns.md) |
| [Acquisition](../assets/templates/acquisition.yaml) | Read flash or memory with repeatability and completeness checks | [Firmware lab](firmware-lab.md) |
| [Firmware experiment](../assets/templates/firmware-experiment.yaml) | Describe a Renode/Qiling or other bounded execution experiment | [Firmware lab](firmware-lab.md) |
| [Bus decoding](../assets/templates/bus-decoding.yaml) | Preserve signal interpretation, CAN database identity, and known-state checks | [Firmware lab](firmware-lab.md) |
| [Fuzz campaign](../assets/templates/fuzz-campaign.yaml) | Specify a harness, AFL++/boofuzz campaign, reset, and failure replay | [Testing](testing-and-constraints.md) |
| [Path query](../assets/templates/path-query.yaml) | Specify symbolic inputs, taint boundaries, constraints, and concrete replay | [Constraints](testing-and-constraints.md) |
| [Format study](../assets/templates/format-study.yaml) | Recover and validate a binary format | [Formats](formats-and-runtimes.md) |
| [Framed record](../assets/templates/framed-record.ksy) and [fixtures](../assets/templates/framed-record-fixtures.yaml) | Adapt a small, bounded Kaitai example and its positive/negative cases | [Formats](formats-and-runtimes.md) |
| [Runtime study](../assets/templates/runtime-study.yaml) | Inspect Wasm, JVM, Python, or Go with the correct identities and boundaries | [Runtimes](formats-and-runtimes.md) |
| [Comparison and inventory](../assets/templates/comparison-inventory.yaml) | Record Diaphora matches, Syft inventory, or capa/FLOSS leads | [Matching and artifacts](matching-and-runtime-artifacts.md) |
| [Memory and replay](../assets/templates/memory-replay.yaml) | Record Volatility analysis or rr execution/replay | [Runtime artifacts](matching-and-runtime-artifacts.md) |
| [Test cases](../assets/templates/test-cases.csv) | Define normal, malformed, and repeatability cases with expected observations | [Testing](testing-and-constraints.md) |
| [Finding](../assets/templates/finding.md) | Deliver the answer with decisive evidence and limits | [Assembly](assembly-patterns.md) |

## Record conventions

- `schema_version` versions the record layout; it does not identify a tool version.
- `record_state: draft` means an uncompleted plan. Use `recorded` for actual observations and retain `partial`, `failed`, or `unavailable` outcomes where appropriate. Completion is never inferred from the presence of a file.
- `null` means unknown or unset. Empty collections have no recorded entries; they do not imply that an inventory or search was complete. Use explicit outcome/completeness fields to state what was checked.
- Digests include the algorithm and hex value. Addresses are strings with an explicit coordinate kind and image/load context. Ranges use inclusive start and exclusive end unless their record says otherwise.
- `argv` is a list of literal arguments, not a shell command. Environment and working directory are recorded separately. A command record does not grant authority to execute it.
- Paths in a completed record are relative to its investigation workspace unless marked absolute. Artifact references preserve the original bytes and transformation chain.
- Timeouts and size limits are selected for the target. A `null` limit is unconfigured, never an implicit unlimited run.
- Result outcomes distinguish an observed negative result from unsupported, unobserved, incomplete, or timed-out analysis. Stubbed behavior and inferred labels retain their authority.

## Minimal use examples

**Firmware command handler.** Copy `toolkit-plan.yaml`, `firmware-experiment.yaml`, and `test-cases.csv`. Bind the image digest, entry point, ABI, required memory/peripherals, input buffer, and stop condition. Start with a known command captured from the matching device. The output consists of the small execution harness, checked reply or state change, and any dependencies represented by stubs.

**Unexpected CAN field.** Copy `bus-decoding.yaml`. Bind the raw capture, channel/time base, database digest, frame ID, and signal hypothesis. Compare two independently known device states and inspect decisive raw frames. Record database-consistent decoding separately from independently validated field meaning.

**Binary parser robustness.** Copy `fuzz-campaign.yaml` and `test-cases.csv`. Define the parser boundary, normal/rejected-input outcomes, reset, time budget, and target coverage. The output is a runnable harness plus replayable findings and campaign coverage, including a zero-finding result with its tested scope.

**Unknown bytecode package.** Copy `runtime-study.yaml`. Identify its container and runtime family before choosing an engine. Bind format/runtime versions and preserve member-to-bytecode coordinates. The output is a supported instruction/interface explanation with unresolved host or native boundaries.

## Synthetic format exercise

The Kaitai example has a 7-byte header followed by at most 1024 payload bytes:

| Offset | Size | Meaning |
| --- | --- | --- |
| 0 | 4 | ASCII `RVMX` |
| 4 | 1 | Version, exactly 1 |
| 5 | 2 | Unsigned little-endian payload length, at most 1024 |
| 7 | Declared length | Payload |

The fixture file supplies hexadecimal input and expected parse outcomes. Generate a parser with a compatible Kaitai compiler/runtime, parse each fixture, and separately enforce exact input consumption. Generated parser behavior must be checked in the chosen language; the schema does not configure a process sandbox or resource supervisor. The fixtures are synthetic data with no target code to execute.

For JavaScript generated by Kaitai 0.11, with the matching runtime installed and `FramedRecord.js` in `generated/`, this reads the valid payload and checks exact consumption:

```javascript
const { FramedRecord } = require('./generated/FramedRecord.js');
const KaitaiStream = require('kaitai-struct/KaitaiStream');
const bytes = Buffer.from('52564d58010300616263', 'hex');
const stream = new KaitaiStream(bytes);
const record = new FramedRecord(stream);
if (stream.pos !== bytes.length) throw new Error('Trailing data');
console.log(Buffer.from(record.payload).toString('hex')); // 616263
```

Bad magic, unsupported version, and excessive declared length are parser validation errors. A short payload is an end-of-input error. The trailing-byte fixture parses a record successfully, then fails the wrapper's exact-consumption check. These are separate test outcomes.
