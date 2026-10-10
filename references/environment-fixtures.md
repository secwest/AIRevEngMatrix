# Development-environment fixtures

These small sources provide known language constructs and observable outputs for evaluating a selected analysis route. They are copied into an investigation workspace; generated binaries, bytecode and build caches stay there. [Expected cases](../assets/fixtures/environment-cases.yaml) specify ten argument/output cases. The [environment study](../assets/templates/environment-study.yaml) records baseline execution and decompiler assessment separately.

## Sources and build profiles

The commands below assume the named source has been copied to the current workspace and each `out/` destination exists. Add the host's executable suffix where needed. Record exact compiler/runtime versions, arguments and output hashes. These are build recipes, not claims that each SDK or decompiler is installed. Probe the selected compiler's options first.

| Family and source | Baseline and comparison profiles | Constructs present |
| --- | --- | --- |
| [C++](../assets/fixtures/environment-patterns.cpp) | `g++ -std=c++17 -O0 -g environment-patterns.cpp -o out/cpp-debug`; comparison `-O2 -s`. For MSVC, use its C++17/exception/debug or optimization flags in a separate recorded build. | Virtual interface, generic wrapper, parse/error and exception path |
| [C#](../assets/fixtures/EnvironmentPatterns.cs), [project](../assets/fixtures/EnvironmentPatterns.csproj) | `dotnet build EnvironmentPatterns.csproj -c Debug -o out/debug`; repeat with Release and `out/release`. Use an installed SDK and matching target reference pack. Run the generated DLL with the matching runtime. | Interface, generic invocation, async state machine, caught error |
| [Java](../assets/fixtures/EnvironmentPatterns.java) | `javac -g -d out/debug EnvironmentPatterns.java`; comparison `javac -g:none -d out/no-debug EnvironmentPatterns.java`. Run `java -cp out/debug EnvironmentPatterns` or its comparison directory. | Interface, generic erasure, lambda, exception path |
| [Go](../assets/fixtures/environment-patterns.go) | `go build -gcflags="all=-N -l" -o out/go-debug environment-patterns.go`; comparison `go build -trimpath -ldflags="-s -w" -o out/go-stripped environment-patterns.go`. | Interface, closure, deferred cleanup |
| [Swift](../assets/fixtures/environment-patterns.swift) | Swift 5.7+ compatible toolchain: `swiftc -Onone -g environment-patterns.swift -o out/swift-debug`; comparison `-O`. | Protocol existential, generic invocation, optional parsing, thrown error |
| [Python](../assets/fixtures/environment_patterns.py) | Run source with the target Python. Use `py_compile.compile` with an explicit output path and `optimize=0` or `optimize=2` to produce separate `.pyc` artifacts, then run those artifacts. | Closure, input parsing, caught exception |
| [JavaScript](../assets/fixtures/environment-patterns.mjs) | `node environment-patterns.mjs`. A bytecode/cached profile must be produced separately with the exact target VM and retained dependencies. | Captured value, async suspension, error path |
| [Dart](../assets/fixtures/environment-patterns.dart) | `dart run environment-patterns.dart`; comparison `dart compile exe environment-patterns.dart -o out/dart-aot`. | Interface, generic wrapper, future/async, caught error |
| [Lua](../assets/fixtures/environment-patterns.lua) | `lua environment-patterns.lua`; comparison `luac -o out/lua-bytecode environment-patterns.lua` followed by the matching interpreter. Compile a stripped variant separately where supported. | Closure/upvalue and protected call |
| [Erlang](../assets/fixtures/environment_patterns.erl) | `erlc +debug_info -o out/debug environment_patterns.erl`; comparison `erlc +no_debug_info -o out/no-debug environment_patterns.erl`. Run `erl -noshell -noinput -pa out/debug -s environment_patterns main -extra` followed by case arguments. | Clauses, guards, tagged success/error values |
| [Rust source](../assets/fixtures/rust-patterns.rs), [Rust cases](../assets/fixtures/rust-patterns.yaml) | Existing debug and optimized profiles are documented in [templates](templates.md). | Trait call, generics, enums/Result and error paths |

Shell quoting differs by host. A stored argument vector passes a compound value such as `all=-N -l` or `-s -w` as one argument. Copying shell quotes into that argument value changes its meaning. Builds are separate artifacts even when they implement the same cases.

## Behavior contract

For the ten listed cases, every new fixture prints a success value or a named error, writes no stderr and exits zero. Go additionally prints `cleanup` on a separate line for every case, including early errors; the YAML records that suffix. This makes a lost deferred cleanup observable. Only CRLF-to-LF stdout normalization is allowed.

Use each YAML `argv` list directly. An empty argument and no argument are different cases. The contract covers the enumerated inputs; it is not a universal cross-language specification for Unicode digits, arbitrary-size numbers or whitespace. Extend the oracle explicitly before comparing those behaviors.

## Decompiler assessment

1. Compile/run the original source for the selected profile and preserve its artifact and baseline outcomes.
2. Analyze that generated artifact using a compatible engine without supplying the reference source as recovered evidence. Retain raw instructions/IR, decompiled output, settings and diagnostics.
3. Check the expected construct in the actual build. Inlining, specialization and dead-code removal can legitimately remove source constructs; do not score an absent source-level shape as an engine failure without instruction evidence.
4. Compare decisive control, return and error/cleanup behavior. Build the reconstruction separately when the output is intended to be compilable; otherwise record instruction checks and supported pseudocode interpretation.
5. Report baseline behavior, engine support, reconstruction correctness and untested profiles independently. A compiler/run check does not certify a decompiler.

## Profiles that require application SDKs

| Environment | Additional fixture needed | Check |
| --- | --- | --- |
| Kotlin/Scala | Compiler-matched coroutine/default-argument or pattern-match/closure example | Generated method and metadata interpretation, including error/resume paths |
| Android | APK with resource callback, DEX method and optional JNI crossing; unminified and minified builds | Resource/descriptor mapping, method body and device observation |
| Apple UI and concurrency | Objective-C selector/block and Swift async/cancellation case in a matched app | Slice/dSYM pairing, callback/continuation and ownership behavior |
| Flutter | Small application containing the Dart case and a platform channel, built for the selected supported architecture | Engine/application pairing, metadata addresses and channel behavior |
| Unity | Small scene with serialized field, managed method/coroutine; separate Mono and IL2CPP exports | Asset/type linkage and actual body recovery |
| Unreal/Godot | Event-driven script/Blueprint plus one resource and a failure branch | Package/engine version, script semantics and matching runtime result |
| LuaJIT/Luau and BEAM/Elixir | Bytecode compiled by the exact variant, with coroutine/upvalue or receive/macro-lowered case | Versioned instruction semantics and retained versus absent debug forms |
| Wasm | Target-compiled C/Rust module with branch, memory access and host import; separate component case if needed | Indices, memory/trap behavior and host ABI |
| Ruby/PHP/scientific/legacy | Captured environment, exceptional cleanup and foreign/data-layout boundary | Exact VM/compiler interpretation and result/shape/encoding behavior |
| EVM | Locally compiled contract with revert, event, storage and proxy context as required | Bytecode versus proposed ABI/control flow under a fixed local state |

These rows are specifications for extending the fixture set to the actual target environment. They are not completed test results or substitutes for the required application artifacts.
