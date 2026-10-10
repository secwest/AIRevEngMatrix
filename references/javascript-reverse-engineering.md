# JavaScript, TypeScript, Node, and Electron environments

Scope: shipped text, bundles/source maps, Electron packages, React Native Hermes, V8 caches and embedded JS runtimes. Records: [environment study](../assets/templates/environment-study.yaml), [VM study](../assets/templates/virtual-machine-study.yaml). Browser/IPC acquisition follows [JavaScript and web](javascript-and-web.md).

## Recovery efforts and tool roles

| Component | Role | Qualification |
| --- | --- | --- |
| Babel, Acorn, SWC, TypeScript APIs and source-map readers | Parse shipped syntax, recover available mapped source and rebuild module relationships | Formatting cannot recreate erased TypeScript types, comments or absent source content. |
| Wakaru and compatible unbundling transforms | Recover supported module and syntax structure | Preserve original/generated coordinates and transform decisions; readable output is still a reconstruction. |
| [hermes-dec](https://github.com/P1sec/hermes-dec) | Supported Hermes HBC parsing, disassembly and partial decompilation | Bind the exact HBC version and unsupported control flow; output need not be executable JavaScript. |
| [View8](https://github.com/suleram/View8) | Reconstruction from supported serialized V8 code | Requires a matching disassembler/runtime format. Its serialized intermediate uses pickle; only load intermediates produced in the trusted workflow. |
| CDP/V8 Inspector and native debuggers | Runtime script, coverage and native/JIT mapping observations | Captured code is tied to a target and time window. Inspector availability is independent of static format support. |

## Workflow by representation

1. Inventory scripts, source maps, bundles, ASAR members, preloads, native addons, Wasm and bytecode caches. Hash retained responses or package members; the same URL/path can contain different builds.
2. For text, parse under the correct script/module/TypeScript syntax and resolve imports using the shipped loader/bundler rules. Recover embedded original source where present; an external map URL is only a reference until acquired.
3. For HBC or V8 caches, bind format/runtime version and selected decoder. Keep function indices, constant tables, instruction offsets, exception information and code-cache dependencies. QuickJS and other engines need their own matching decoder; View8 is not a universal snapshot parser.
4. Trace closures, async/generator lowering, dynamic imports, callbacks and event registration. A property name can be computed or replaced at runtime. Track receiver/prototype context before treating a property access as a resolved call.
5. Follow native boundaries: Electron main/preload/renderer IPC, Node addons, React Native bridges, Wasm imports and browser APIs. Record serializers, argument shape and authority at the crossing.
6. Verify important transformations against AST/bytecode and controlled observations. Preserve error and promise-rejection behavior; a fulfilled happy path can conceal changed cleanup or scheduling.

## Representative assessment

The [JavaScript fixture](../assets/fixtures/environment-patterns.mjs) uses a captured value, async suspension and exception handling. Its [profiles](environment-fixtures.md) check source behavior on Node. It does not certify HBC/V8 decompilation: produce a second artifact with the exact target compiler/cache format and repeat the checks on that artifact's reconstruction.

For a bundled app, add one static import, one computed/dynamic import, a source-map location and an IPC/native boundary. For TypeScript, retain the original source only as fixture ground truth and identify which type information was erased. A proposed recovered type needs runtime/usage evidence.

**Deliverable:** recovered text or pseudocode with its origin, module/callback relationships, checked output mappings and runtime/native gaps. Never describe prettified text or an object dump as recovered original TypeScript.
