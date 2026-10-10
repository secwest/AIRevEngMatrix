# Graph and evidence conventions

These structures support traceable joins, portable results, audits, and reconstruction ledgers. A single finding needs only enough source detail to verify it; repeated cross-layer analysis benefits from the fuller data model.

## Data model

Represent each target as an immutable artifact identity: SHA-256 of original bytes, size, acquisition path/URL, acquisition time, and container member path when applicable. For a transformed artifact retain parent identity, transform name/version, parameters, output digest, and exact input byte range if known. For live targets record process/device/browser target identity and attach/start/end times; a live identity is not a substitute for a file digest.

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

An unknown ledger records ID, question, affected claim, reason, evidence needed to resolve it, status, and resolution evidence. Status moves to resolved only when new evidence explicitly answers the question; deleting or renaming an unknown does not resolve it.

Repeated queries over a completed analysis use one stored result and bounded deterministic views: summary, binary layout sections/symbols/mitigations/linkage, JavaScript modules/assets, or native procedure/pseudocode/assembly/blocks/references. Each view names its parent result ID, selector, offset and limit, and returns a digest of the selected material. A view does not rerun analysis or imply that an omitted page is absent. Stable node IDs disambiguate paths.

## Provider interface

A small adapter can expose `probe()` (installed/compatible/version/host), `open(target)`, `run(request, limits)`, and `close()`. Return structured facts plus raw output references and typed errors: `invalid_input`, `unsupported_target`, `capability_unavailable`, `permission_denied`, `timeout`, `partial_capture`, `artifact_changed`, `producer_failed`. Keep availability separate from advertised capability. Use a session registry only when stateful engines are needed; identify sessions by exact artifact digest and provider instance. On each operation verify the file still matches the session digest or mark coordinates unverified.

Command adapters use argument vectors without shell interpolation and record executable path and version, working directory, selected environment overrides, exit code, bounded stdout/stderr, and timeout. Parser limits cover input size, recursion, decompression ratio, object count, and output volume. Execution of untrusted code requires runtime evidence and authorization; a temp directory and resource limits are not a security sandbox. Timeout or cancellation cleanup includes owned child processes and temporary files, with any failure recorded.

## Coordinate and join rules

- Keep file offset, container offset, slice-relative offset, image virtual address, runtime address, source generated span, and original source span as distinct types. Translate only with an explicit mapping whose source digest matches. For a Mach-O universal binary, original offset = slice offset + slice-relative offset. For a loaded image, runtime address = image base + relative virtual address, with relocation and slide recorded.
- A decompiler line, symbol name, route string, or stack frame is not by itself proof of runtime execution. A join requires matching artifact identity plus an address/span/token mapping, or a recorded runtime event with corroborating module identity.
- Normalize comparisons by stable identity first: hashes, type/member tokens within one build, symbol plus signature, instruction bytes, AST shape, or content-defined similarity. Report ambiguous matches and moved/renamed candidates separately. Never equate two build-local addresses or metadata tokens without a mapping.
- Preserve negative evidence only with an explicit observation scope: enabled domains, target selection, sampling policy, start/end, loss counters, and filtering. Missing capture before attach or after detach is unknown, not a negative finding.

## Verification gate

Before relying on a new adapter, use a small fixture with known values and one target-specific check. Useful checks: archive member digest matches raw extraction; parsed section offsets fit within the file; virtual-to-file mapping round trips; source-map generated position maps to an expected original span; managed token resolves to the expected signature; ADB pull digest equals the acquired file; browser event order and screenshot metadata match the scenario; a comparison against identical inputs yields no changes. For claims that depend on opaque producer output, inspect a raw sample and disclose the producer's limits.

A reproducible package contains the source scripts, dependency versions, fixture or validation command, evidence bundle, and a short result report. A permanent service is a separate deployment choice, not part of an ordinary analysis package.
