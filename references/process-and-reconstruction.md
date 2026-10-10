# Process, comparison, and reconstruction build recipes

These workflows produce run comparisons, changed-behavior findings and reconstruction verification results. Read [the graph and evidence conventions](evidence-and-runtime.md) when the result needs formal provenance or repeated cross-layer joins. A joined graph or passing test cannot strengthen weak or missing source evidence by itself.

## Process scenario harness

A scenario declares executable and argument vector, working directory, selected environment overrides, stdin or PTY interaction schedule, timeout, expected exits, files/directories to snapshot, and optional process/event tracing. Build a harness using the host's process API. Use a PTY when terminal behavior is part of the question; use pipes when it is not. On Windows, use a verified ConPTY/Job Object or equivalent if child-tree control is required, otherwise report that the host cannot provide equivalent capture. Do not claim a Linux/WSL process run observes a native Windows process.

Before launch, hash executable and declared inputs and snapshot selected paths. During run, record monotonic timestamps, stdout/stderr or terminal bytes, scheduled input, exit/signal, child processes when observable, and dropped/truncated data. After run, snapshot selected files with hashes and sizes. The harness observes selected paths; it does not confine the program to them. The inherited environment and external services may affect behavior. Set output caps and process-tree cleanup; failure to kill descendants is a capture limitation. A saved capture can be compared on any host without rerunning the target.

Compare two captures by scenario version, target identity and environment first. Then align terminal events, exit state, filesystem effects and optional traces. Mark nondeterministic fields such as timestamps, PIDs and generated IDs explicitly, with normalization rules declared before diffing. Return equal, different, missing and uncomparable observations. No output difference under one scenario proves only that scenario's observations agreed.

## Protocol behavior and remote observability

For a protocol result, start from an authorized capture or test endpoint. Preserve raw messages, direction, transport, endpoint identity and timing. Determine framing before decoding fields; separate wire bytes from inferred field names. Vary one controlled input at a time to test length fields, ordering, state transitions, error behavior and version negotiation. A parser should reject malformed lengths and truncated frames explicitly. Do not infer encrypted payload contents from metadata alone.

For remote fingerprintability, state the vantage point and what a remote peer can actually observe: headers, banners, TLS or protocol negotiation, response shapes, timing distributions, error codes, redirect patterns, resource paths or stable identifiers. Test stability across sessions, configurations and versions, with a control service or alternative implementation where possible. Report the preconditions for each signal and whether it identifies a product, version family, configuration or only a broad technology class. A local code trait is remotely fingerprintable only if a reachable path makes it observable. Keep probes within the user's authorized target and rate limits.

## Cross-artifact comparisons

For artifacts, compare exact bytes, parsed structure and extracted members. For JavaScript bundles, compare entries, module relationships, chunks, assets and mappings. For functions, compare known matched functions using normalized instructions, CFG, decompiler output as supporting evidence, and call edges. For web captures and screenshots, compare capture settings/coverage first, then event sets or images. For managed members, use signatures and IL normalization rather than token numbers across builds. Every result should expose the alignment key and ambiguous matches.

A changed-behavior finding is a synthesis: choose a user-visible feature or externally observable effect, align its traces across versions, and identify changed supported steps and scenario outcomes. Report a candidate when only static code changed; report observed behavior only when comparable runtime scenarios show it.

## Feature explanations and static/runtime correlation

Deliver an explained feature path or behavior finding. Internally, typed nodes can represent artifacts, processes, modules, functions/methods, UI elements, routes, IPC channels, endpoints, device components and observations. An edge should retain source location, authority and version scope. Graph projections from Apple, Android, managed and JavaScript analysis are optional ingest adapters. Bounded path searches should explain each supported step; do not invent missing links.

To correlate static and runtime evidence, require a matching module/package/bundle digest or build ID, plus a mapping from runtime address/script ID/token to a static location. When runtime identity cannot be proven, label the correlation tentative. Retain the observed event and static candidate as separate records.

## Reconstruction verification

Deliver a coverage and parity finding against concrete claims: API/entry point, input schema or domain type, side effect, error case, UI interaction, persistence rule, or scenario outcome. When there are many claims, track them in an obligation ledger with source, required fixtures/cases, owner, dependencies, status and verifier. Static findings create candidate obligations; they cannot alone close runtime obligations. Allow analyst-reviewed additions and exclusions with recorded reasons.

A reconstruction manifest binds each obligation to exactly one implementation owner and any required type/schema. A verifier has its own result, exact case IDs, reconstruction build identity, authority and raw output. Closure requires all required cases to pass under comparable authority; unresolved unknowns, duplicate owners, contradictions, missing dependencies or uncomparable environments keep an obligation open. Do not compute a single coverage percentage that hides required open obligations; report counts by required/optional, authority and status.

Reconstruction verification runs a selected set of fixtures and comparisons against an original or authoritative trace. Record what was run and what was not. If a ledger is used, summarize its status with links to each verifier. Managed and other source-to-rebuild mappings require unique original identities before their results feed the ledger.

## Evidence and unknown management

When a result needs portable provenance, implement export/import as a digest-checked bundle described in [the conventions](evidence-and-runtime.md). A bundle contains selected records and sources, not merely a prose summary. If unknowns are tracked, resolving one requires new supporting material and a check that it answers the original question. Navigation and address context should return bounded adjacent source/assembly/data facts tied to the same artifact identity.

## Acceptance examples

- Running an identical deterministic fixture twice yields no capture diff after declared normalization; changing one output yields a localized difference.
- An application graph path identifies the source record for every edge and refuses a path across mismatched build IDs.
- An obligation with a passing static check but missing runtime fixture remains open; adding a comparable passing runtime verifier closes it.
- A tampered exported evidence file fails import digest verification.
