# Optional graph and evidence conventions

Read this when a result depends on traceable joins, must be transported or audited, or requires a reconstruction ledger. It documents supporting structures; ordinary analysis should return the requested result with enough source detail to check it. A small one-off script does not need this full model.

## Data model

Represent each target as an immutable artifact identity: SHA-256 of original bytes, size, acquisition path/URL, acquisition time, and container member path when applicable. For a transformed artifact retain parent identity, transform name/version, parameters, output digest, and exact input byte range if known. For live targets record process/device/browser target identity and attach/start/end times; a live identity is not a substitute for a file digest.

Each evidence record should contain:

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

Do not claim that JSON alone authenticates evidence. For portable bundles, create a manifest of relative paths, sizes, SHA-256 digests, schema version, and a canonical digest of the manifest. Optional signatures require a real signing key and verification step. On import, verify every referenced file and reject path traversal, duplicate normalized paths, digest mismatch, unknown required schema versions, and missing records. Never execute imported content. If only a saved extract exists, describe it as a historical snapshot.

Use a separate unknown ledger: ID, question, affected claim, reason, evidence needed to resolve it, status, and resolution evidence. Status moves to resolved only when new evidence explicitly answers the question; deleting or renaming an unknown does not resolve it.

For repeated queries over a completed analysis, store the result once and provide bounded deterministic views: summary, binary layout sections/symbols/mitigations/linkage, JavaScript modules/assets, or native procedure/pseudocode/assembly/blocks/references. Each view names its parent result ID, selector, offset and limit, and returns a digest of the selected material. A view does not rerun analysis or imply that an omitted page is absent. Use stable node IDs when a path is ambiguous.

## Provider interface

A small adapter can expose `probe()` (installed/compatible/version/host), `open(target)`, `run(request, limits)`, and `close()`. Return structured facts plus raw output references and typed errors: `invalid_input`, `unsupported_target`, `capability_unavailable`, `permission_denied`, `timeout`, `partial_capture`, `artifact_changed`, `producer_failed`. Keep availability separate from advertised capability. Use a session registry only when stateful engines are needed; identify sessions by exact artifact digest and provider instance. On each operation verify the file still matches the session digest or mark coordinates unverified.

For commands, pass an argument vector with no shell interpolation; record executable absolute path and version, working directory, selected environment overrides, exit code, bounded stdout/stderr, and timeout. For parsers, cap input size, recursion, decompression ratio, object count, and output volume. Run untrusted executables only when the task requires runtime evidence and the user/host authorizes execution; a temp directory and limits do not constitute a security sandbox. Cleanup owned child processes and temporary files on timeout or cancellation, then report any cleanup failure.

## Coordinate and join rules

- Keep file offset, container offset, slice-relative offset, image virtual address, runtime address, source generated span, and original source span as distinct types. Translate only with an explicit mapping whose source digest matches. For a Mach-O universal binary, original offset = slice offset + slice-relative offset. For a loaded image, runtime address = image base + relative virtual address, with relocation and slide recorded.
- A decompiler line, symbol name, route string, or stack frame is not by itself proof of runtime execution. A join requires matching artifact identity plus an address/span/token mapping, or a recorded runtime event with corroborating module identity.
- Normalize comparisons by stable identity first: hashes, type/member tokens within one build, symbol plus signature, instruction bytes, AST shape, or content-defined similarity. Report ambiguous matches and moved/renamed candidates separately. Never equate two build-local addresses or metadata tokens without a mapping.
- Preserve negative evidence only with an explicit observation scope: enabled domains, target selection, sampling policy, start/end, loss counters, and filtering. Missing capture before attach or after detach is unknown, not a negative finding.

## Verification gate

Before relying on a new adapter, use a small fixture with known values and one target-specific check. Useful checks: archive member digest matches raw extraction; parsed section offsets fit within the file; virtual-to-file mapping round trips; source-map generated position maps to an expected original span; managed token resolves to the expected signature; ADB pull digest equals the acquired file; browser event order and screenshot metadata match the scenario; a comparison against identical inputs yields no changes. For claims that depend on opaque producer output, inspect a raw sample and disclose the producer's limits.

Deliver the smallest reproducible package: source script(s), dependency versions, fixture or validation command, evidence bundle, and a short result report. Do not create a permanent general-purpose service unless the user actually needs one.
