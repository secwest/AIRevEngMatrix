# JavaScript, Electron, and web analysis

Shipped-source analysis and runtime observation are separate processes. Parsing a JavaScript artifact does not require executing it. Formal cross-layer joins and portable provenance follow the [graph and evidence conventions](evidence-and-runtime.md).

The [JavaScript development-environment workflow](javascript-reverse-engineering.md) adds compiler/language interpretation, Hermes and V8 recovery efforts, and source-versus-bytecode fixture requirements to these package and capture methods.

| Result capability | Minimal implementation | Required output and validation |
| --- | --- | --- |
| Package and application intake | Inventory directory, ZIP, or Electron ASAR using a bounded reader such as `@electron/asar`, with path-safe extraction and digests. Include declared external ASAR members. Read package.json, Electron main/preload/renderer entries, HTML script tags, import maps, source maps, and chunk manifests. | File graph with exact member paths/digests and acquisition gaps; verify one resolved entry and one extracted member digest. |
| Static JS analysis | Parse with Babel, Acorn, SWC, or TypeScript AST configured for the syntax actually present. Build module import/re-export graph, symbol definitions/references, call sites, object property flow, IPC endpoints, routes, network endpoint candidates, and interface declarations. | Each edge cites generated file/span and parse mode. Dynamic require, computed property, eval, minified aliasing, and reflection create explicit unresolved edges. |
| Feature explanation | Trace from a user-visible anchor through package roles, modules, exports, UI routes/components, IPC channels, network calls, native add-ons and persistence boundaries. Use a typed graph internally if it helps. | Return the supported behavior chain with source locations and unresolved steps. Mere graph reachability is not proof of execution. |
| Source location and recovery | Decode source maps using a compatible mapping library; verify sourceMappingURL, map URL/base, generated file identity, names and sourcesContent. For code without maps, pretty-print or use an installed recovery engine such as Wakaru in a nonexecuting mode. | Preserve generated span, original source span, and mapping provenance. Recovered modules are hypotheses, not original files. |
| Browser target discovery/page capture | Connect to a user-selected Chrome DevTools Protocol endpoint and enumerate page targets. Attach chosen target; collect URL, title, DOM/accessibility snapshot, script inventory, resources, console, network, workers, storage key names or explicitly requested values. | Record target ID, attach/start/end, domains enabled, truncation/redaction, and missing pre-attach events. Bound DOM depth, source size and response body. |
| Passive web session/runtime | Subscribe to CDP Page, Network, Runtime, Debugger, DOMDebugger, and related domains as needed. Correlate navigation, reload, script parse, request/response, WebSocket metadata, console, exceptions, and listener metadata by timestamp and target/frame ID. | Do not claim events before attach. Avoid evaluating target expressions when passive capture suffices; if Runtime.evaluate is needed, label the evaluation and its effects. |
| Web bundle inspection | Parse captured script bytes as static artifacts. Identify webpack/Vite/Rollup or other chunk wrappers by syntax, not name alone; recover import and dynamic-import edges, route and endpoint strings, worker registrations, and advertised browser tool declarations. | Separate literal facts from inferred framework fingerprints and callable interface candidates. Verify chunk URL resolution against page origin/import map. |
| Website script export | Save exact Debugger script source or captured response bytes with URL, script ID, content digest, MIME, response provenance, and generated-to-original mapping where valid. Preserve sourcemap files and sourcesContent as distinct artifacts. | Rehash exported bytes. Inline/eval/data scripts need distinct synthetic identities; URL alone may not identify content. |
| Network capture import | Parse HAR, CDP event log, or mitmproxy native capture into request/response pairs using IDs and redirect chains. Retain method, sanitized URL, headers, status, timing, body presence/size/digest, and capture gaps. | A HAR may omit bodies or TLS details. Redact credentials/tokens in reports while preserving a private raw copy only if needed and authorized. |
| Active browser scenario | Use Playwright or a CDP client with a declarative action list: launch/connect, navigation, click/type/keyboard/wait/assert, screenshots, selected network/storage capture. Set viewport, locale, timezone, color scheme, reduced motion, service-worker policy and storage seed explicitly. | Record each action, timestamp, result, page/frame, failure, screenshot digest and final URL. A scenario can alter remote state; use only when authorized. |
| Electron/runtime observation | Discover Electron windows and Node/V8 inspector targets; correlate process, window, context, script URL and package digest. Observe loaded scripts, IPC messages where accessible, console, exceptions and selected call stacks. | Version-gate Electron/Inspector methods; distinguish renderer, preload, main and child processes. No inspector access means that edge remains unavailable. |
| Screenshots and visual diff | Capture PNG plus viewport/device scale and page state. Compare same-sized images by pixel/perceptual metrics and diff mask, while reporting rendering nondeterminism. | Identical viewport and deterministic fixture should yield zero or explained diff; image similarity does not prove behavioral equivalence. |
| WebMCP discovery | If the selected browser exposes an experimental WebMCP interface, feature-detect and enumerate only advertised tool names/schemas through its documented API. | An advertisement is not permission to invoke a tool. Unsupported browsers return unavailable rather than fabricated declarations. |

## Static tracing algorithm

Start at concrete entry points and parse only reachable files, then expand when the question requires it. Resolve paths using the actual runtime or bundler rules: CommonJS, ESM, browser import maps, and conditional package exports can select different files. Retain the resolution mode, conditions, and failures instead of applying one extension/index search to every target. Track symbol import/re-export chains and direct call sites. For Electron IPC, match channel literals and sender/handler contexts; computed channel names remain candidates. For source-to-bundle comparison, normalize ASTs and map original modules to generated chunks by source maps, exact strings, export shape, and call structure; report collisions and missing maps. For version comparison, use the same parser settings and compare stable roles/edges before raw names.

An ASAR inventory includes entries marked as unpacked and their companion files, commonly under `app.asar.unpacked`. Missing external files make acquisition partial. Format-defined shared member spans are valid when their indexed lengths and contents agree; overlapping ranges alone do not establish corruption. The [ASAR format and tooling](https://github.com/electron/asar) describe external members and shared storage.

## Semantic and export-shape comparison

Static value queries track the selected binding through assignments, direct arguments/parameters, returns, and lexical captures using scope-aware identities. Unknown aliases, computed properties, dynamic imports and reflective calls remain unresolved. Every dependency carries its source span and relation type; a lexical capture does not prove when a closure executes.

Export-shape comparison starts with an exact module/export selector on each side and enumerates supported static return variants. Each property records presence separately from whether its value can be resolved. Variant pairing requires a unique supported discriminator or an explicit reviewed mapping; arbitrary array order is insufficient. A property is absent only when its parent shape has complete coverage. The result gives property-path changes, source spans, unmatched variants and dynamic/unknown values. It establishes static shape differences; observed return values need a separate runtime check.

## Source-map accuracy

Mappings depend on the exact generated text, map URL, `sourceRoot`, source entries, and indexed-map sections where present. A map can supply locations while omitting original text; missing `sourcesContent` does not establish that source files are available. Referenced URLs or paths are untrusted locations and are resolved only within the investigation's acquisition scope. A stale map or a merely similar bundle does not establish an identity match.

The [source-map specification](https://tc39.es/ecma426/) uses UTF-16 code units for JavaScript/CSS column offsets. Byte offsets and Unicode code-point counts can disagree with those coordinates. Each adapter records its API's line/column base and mapping bias; an unmapped span remains unmapped. A useful fixture includes a non-ASCII character and an unmapped generated span. Formatting or inferred module recovery retains its distinction from source text actually supplied by the build.

## Browser capture rules

Passive capture attaches to an existing user-owned target. It should not navigate, click, type, or run page code as part of observation. Chrome's CDP can collect network and console data only after the relevant domains are enabled; record the gap. Response bodies may be unavailable after detach or because the browser did not retain them. A page may make ordinary network requests after attachment. Treat captured storage contents and bodies as potentially sensitive; collect only fields needed for the question.

An active scenario is separate. Prefer a fresh browser context for reproducibility. Explicitly choose whether service workers are blocked or allowed, whether cookies/storage are seeded, and whether the browser is headless. Observe redirects and target closure. Verify the final state with an assertion, not only a screenshot. Use a fixture for first-run validation before targeting a live service.

## Instrumented execution and listener inspection

Precise execution coverage is an instrumented mode with an explicit arm/start/stop sequence. The capture records script identity and text digest, nested function/block ranges, counts, coordinate units, and the interval during which counters were active. Enabling instrumentation can reset counters or affect optimization. Navigation, worker attachment and script replacement determine coverage boundaries. Counts apply to that capture and do not establish which user action caused execution. Teardown stops owned instrumentation and releases the transport while preserving an externally owned page.

Listener inspection binds a selector to an exact document and states its match policy. It returns directly registered listener flags, callback/script location and available source identity. Delegated ancestor listeners, framework dispatch and execution history require separate evidence. Inspection does not dispatch the event. Temporary remote object handles are released after capture.

## Owned Electron scenarios

An Electron scenario records executable/package identity, launch environment, process ownership, and stable window/WebContents selectors before applying actions. A trusted capture harness can subscribe to main-process, window, preload, session, navigation and IPC metadata, with each available event family declared. A renderer-only connection cannot supply all those facts.

Actions can include clicks and waits, targeted renderer reload/crash, and synthetic open-url or second-instance delivery when the selected harness supports them. Synthetic delivery is labeled separately from an actual operating-system event. External navigation, shell launches, downloads, permissions and updater effects have an explicit allow/block policy and observable outcomes. Instrumentation and blocking can alter behavior; payload values are collected only when the question needs them. Cancellation stops owned work, attempts process-tree cleanup and preserves collected observations if cleanup fails.

## Runtime reconciliation

Join a loaded script to shipped code only when bytes or a reliable source-map relationship match. A script URL, bundle filename, or process title can change. For an Electron feature trace, a useful minimal chain is UI event -> renderer handler -> IPC channel -> main handler -> filesystem/network/native call, with evidence for each edge. If one layer is not observable, keep an unknown rather than filling it from naming conventions.

## Acceptance examples

- An ASAR member's extracted digest matches its indexed bytes, and the selected entry points resolve.
- An ASAR with a missing unpacked member reports partial acquisition; valid shared spans remain readable.
- A source-map lookup maps a known generated position to the expected original file/line.
- A passive capture includes its attach window and does not claim a request that completed before attachment.
- Repeating a browser fixture scenario records the same action sequence and expected final assertion.
