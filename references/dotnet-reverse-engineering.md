# .NET, CLR, and Visual Studio environments

Scope: C#, F#, VB.NET, managed C++, Mono, ordinary CLR assemblies, single-file deployment, ReadyToRun and Native AOT. Records: [environment study](../assets/templates/environment-study.yaml), [decompilation study](../assets/templates/decompilation-study.yaml). Package and device operations remain in [managed/mobile methods](managed-mobile-firmware.md).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| [ILSpy / ILSpyCmd / ICSharpCode.Decompiler](https://github.com/icsharpcode/ILSpy) | C# reconstruction, assembly navigation and supported resource/ReadyToRun inspection | API and CLI allow direct use. Record engine revision and output language settings. |
| [dnSpyEx](https://github.com/dnSpyEx/dnSpy) | Managed browsing, decompilation and debugger workflows | Debugger attachment, evaluation and assembly editing have separate effects from offline decompilation. |
| [dotPeek](https://www.jetbrains.com/decompiler/) | Alternative .NET decompilation and assembly browsing | Verify the available export/automation surface; a GUI feature is not automatically a scriptable API. |
| dnlib, dnfile, System.Reflection.Metadata, `ildasm` | Metadata/CIL inspection and token-based checks | Read metadata without loading the target assembly or executing attributes. |

## Select the deployment route

Inventory the carrier, CLI header, assemblies, modules, resources, runtime configuration, dependencies and symbols. Resolve bundle members before assuming a single executable is all native. Keep extracted assemblies tied to their original container. ReadyToRun can retain CIL alongside native code; inspect each available representation.

[Native AOT](https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/) needs native analysis when ordinary method CIL is absent. Available metadata, reflection tables and symbols can support recovery but do not make every method decompilable by ILSpy. C++/CLI and interop libraries can mix representations within the feature being studied.

## Reconstruct a feature

1. Bind assembly/module identity, metadata tokens, method signatures and dependency versions. Tokens are local to a build; use descriptors and evidence when matching another release.
2. Decompile the selected type/method and retain CIL, exception regions and diagnostics. Separate source-like reconstruction from method bodies the engine could not recover.
3. Trace generated members back to the feature: async/iterator state machines, closures, delegates, event accessors and compiler-generated backing fields. Preserve the lowered members where they explain execution.
4. Resolve virtual/interface dispatch, reflection strings, dynamic binding and generated code only as far as metadata or a bounded run supports. Distinguish an available method from one actually selected at runtime.
5. Follow P/Invoke, COM or unmanaged callbacks with native module identity, calling convention, marshalling widths, ownership and error semantics. A declaration is not a resolved binding.
6. Join resource IDs and UI callbacks where required. BAML/XAML reconstruction and serialized resources need their own source identity and parser result.

## Language and runtime traps

| Family | Decisive checks |
| --- | --- |
| C# | Async suspension/resumption, iterator disposal, exception filters, `checked` arithmetic and ref/value semantics |
| F# | Discriminated-union tags, tuple/record structure, closures and pattern-match fallbacks; C# output may lose F# syntax |
| VB.NET | Late binding, conversion helpers, default members and exception behavior; C# output may obscure compiler helpers |
| Trimmed/obfuscated builds | Removed members, renamed identifiers, altered control flow and unavailable reflection targets remain explicit |
| AOT/ReadyToRun | Native address/CIL mappings, generic sharing, runtime fixups and the exact selected body |

## Representative assessment

The [C# fixture](../assets/fixtures/EnvironmentPatterns.cs) uses an interface, generic wrapper, async lowering and a caught failure. [Build profiles](environment-fixtures.md) exercise Debug and Release. A CLR fixture does not certify Native AOT, Unity IL2CPP, F# or VB.NET: add a matching build with a discriminated union, late-bound call, interop boundary or publication mode when relevant.

Check returned output, CIL branches, exception ranges and the generated state-machine body. For a reconstruction, build it separately and compare required cases under the same runtime/dependencies.

**Deliverable:** reconstructed members with token/signature anchors, checked generated-code interpretation, resource/native bindings and missing dependencies. Project export alone does not establish a complete or equivalent application.
