# Graph and evidence conventions

These structures support traceable joins, portable results, audits, and reconstruction ledgers. A single finding needs only enough source detail to verify it; repeated cross-layer analysis benefits from the fuller data model.

## Data model

Represent each target as an immutable artifact identity: SHA-256 of original bytes, size, acquisition path/URL, acquisition time, and container member path when applicable. For a transformed artifact retain parent identities, transform name/version, parameters, output digest, and input ranges or extents where known. A decompression or multi-input reconstruction need not provide a one-to-one byte mapping. For live targets record process/device/browser target identity and attach/start/end times; a live identity is not a substitute for a file digest.

An evidence record has this structure:

```json
{
  "id": "stable hash of canonical record fields",
  "kind": "observation | producer_report | static_inference | runtime_observation | comparison",
  "claim": "one narrow factual statement",
  "artifact_id": "sha256:... or live target ID",
  "location": {"coordinate": "file_offset | virtual_address | source_span | URL | managed_token | timestamp", "value": "..."},
  "producer": {"tool": "...", "version": "...", "command_or_api": "...", "options": {}},
  "raw_ref": "path or content digest of preserved raw output",
  "coverage": {"scope": "...", "start": null, "end": null, "complete": false},
  "confidence": "observed | derived | candidate",
  "limitations": []
}
```

JSON serialization alone does not authenticate evidence. A portable bundle has a manifest of relative paths, sizes, SHA-256 digests, schema version, and a canonical digest of the manifest. Optional signatures require a real signing key and verification step. Import verification rejects path traversal, duplicate normalized paths, digest mismatch, unknown required schema versions, and missing records. Imported content is data, not executable code. A saved extract represents a historical snapshot.

The schema above is illustrative. A portable implementation defines the canonical serialization, field set, and schema version before deriving record IDs. A record ID excludes its own `id` field; a manifest digest excludes its own digest and signature fields. Missing, null, and empty values remain distinct under the chosen rules. Unsigned hashes detect mismatches against the manifest but cannot establish who produced it. Bundle imports also enforce size/count limits and reject link entries or destination collisions that could escape or overwrite the selected extraction tree.

An unknown ledger records ID, question, affected claim, reason, evidence needed to resolve it, status, and resolution evidence. Status moves to resolved only when new evidence explicitly answers the question; deleting or renaming an unknown does not resolve it.

Repeated queries over a completed analysis use one stored result and bounded deterministic views: summary, binary layout sections/symbols/mitigations/linkage, JavaScript modules/assets, or native procedure/pseudocode/assembly/blocks/references. Each view names its parent result ID, selector, offset and limit, and returns a digest of the selected material. A view does not rerun analysis or imply that an omitted page is absent. Stable node IDs disambiguate paths.

## Provider interface

The optional adapter shape is described in [toolkit assembly](assembly-patterns.md). Results can include raw output references and typed errors: `invalid_input`, `unsupported_target`, `capability_unavailable`, `permission_denied`, `timeout`, `partial_capture`, `artifact_changed`, `producer_failed`. Availability is separate from advertised capability. A session registry is useful when stateful engines are needed; sessions identify the exact artifact digest and provider instance. Results from a stale session retain their original artifact identity instead of being relabeled as analysis of a changed file.

Command adapters use argument vectors without shell interpolation and record executable path and version, working directory, selected environment overrides, exit code, bounded stdout/stderr, and timeout. Parser limits cover input size, recursion, decompression ratio, object count, and output volume. Execution of untrusted code requires runtime evidence and authorization; a temp directory and resource limits are not a security sandbox. Timeout or cancellation cleanup includes owned child processes and temporary files, with any failure recorded.

## Coordinate and join rules

- Keep file offset, container offset, slice-relative offset, image virtual address, runtime address, source generated span, and original source span as distinct types. Translation requires an explicit mapping whose source digest matches. For a Mach-O universal binary, original offset = slice offset + slice-relative offset for validated file-backed bytes. A PE runtime address is load base + RVA; ELF and Mach-O linked virtual addresses use the appropriate load bias or slide. Zero-fill, runtime allocations, and MMIO can have no file offset. Compressed data and logical extents retain transformation-specific maps instead of a guessed constant offset.
- A decompiler line, symbol name, route string, or stack frame is not by itself proof of runtime execution. A join requires matching artifact identity plus an address/span/token mapping, or a recorded runtime event with corroborating module identity.
- Normalize comparisons by stable identity first: hashes, type/member tokens within one build, symbol plus signature, instruction bytes, AST shape, or content-defined similarity. Report ambiguous matches and moved/renamed candidates separately. Never equate two build-local addresses or metadata tokens without a mapping.
- Preserve negative evidence only with an explicit observation scope: enabled domains, target selection, sampling policy, start/end, loss counters, and filtering. Missing capture before attach or after detach is unknown, not a negative finding.

## Verification gate

Before relying on a new adapter, use a small fixture with known values and one target-specific check. Useful checks: archive member digest matches raw extraction; file-backed section ranges fit within the file; file-backed address mapping round trips; source-map generated position maps to an expected original span; managed token resolves to the expected signature; acquired APK digest is stable and matches a device-side digest when available; browser event order and screenshot metadata match the scenario; a comparison against identical inputs yields no changes. A local digest alone identifies the acquired file but cannot prove complete acquisition. For claims that depend on opaque producer output, inspect a raw sample and disclose the producer's limits.

A reproducible result contains the commands or scripts actually used, dependency versions, relevant checks, and a short finding with decisive source references. An evidence bundle is optional when portable records are needed. A permanent service is a separate deployment choice, not part of an ordinary analysis package.
