# WebAssembly development environments

Scope: Rust/C/C++/AssemblyScript and other languages compiled to core Wasm, component-model artifacts and embedding runtimes. Records: [environment study](../assets/templates/environment-study.yaml), [runtime study](../assets/templates/runtime-study.yaml).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| [WABT](https://github.com/WebAssembly/wabt) | `wasm-decompile`, instruction/text views and format tools | Produces Wasm-oriented pseudocode; check the enabled proposals and tool revision. |
| [wasm-tools](https://github.com/bytecodealliance/wasm-tools) | Validation, textual/structural views and supported component interfaces | Core modules and components need different indexing/interface treatment. |
| Compatible native/IR analyzer | Additional data-flow or host-code analysis | Establish Wasm lifting/feature support before selecting it; native JIT bytes are another representation. |
| Matching embedding runtime/debugger | Concrete import, memory and exported-function observations | Record host functions, limits and runtime settings; a module alone does not specify external effects. |

## Recovery procedure

1. Identify module/component, feature set and compiler/producer/name/debug metadata where available. Bind original bytes before generating WAT or pseudocode. Absent names do not remove function/type indices.
2. Validate the selected feature set. Inventory imports/exports, tables, memories, data/element segments, globals, start functions and custom sections. Nested component/core indices retain their owner identity.
3. Decompile one export and compare structured branches, stack effects, indirect calls, exception/trap behavior and memory operations against instructions. Track address arithmetic and data segments separately from function indices.
4. Recover the language runtime only where evidence supports it: allocator/stack conventions, GC/reference types, Rust panic paths, Emscripten glue or AssemblyScript object conventions. Wasm pseudocode does not identify the original source language by itself.
5. Trace the host ABI: string/buffer encoding, memory ownership, handle tables, callbacks and component canonical lifting/lowering where applicable. WASI imports and browser APIs establish different environments.
6. Run known exports with controlled imports and limits if behavior is required. Instantiation can invoke a start function. Test memory bounds, integer widths, traps and relevant numeric edge cases rather than only successful calls.

## Representative assessment

Use the [environment fixture specification](environment-fixtures.md) to compile a small existing C/Rust case to Wasm with the target toolchain, retaining import and memory settings. A native build is not a Wasm fixture. Add an exported branch, one memory access and one imported callback; for components, add a string/record boundary and resource lifetime case.

Record the original export results and traps, then compare reconstructed behavior under the same host implementation. Round-trip WAT validation checks representation, while runtime cases check a selected behavior. Neither establishes recovery of source-level templates, lifetimes or TypeScript types.

**Deliverable:** pseudocode/instruction explanation, module/component coordinates, checked host interface and exact feature/runtime gaps. Keep optimized-away source abstractions explicitly unrecovered.
