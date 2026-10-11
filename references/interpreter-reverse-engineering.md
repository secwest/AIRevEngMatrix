# Lua, BEAM, Ruby, and PHP environments

These runtimes need version-specific decoders and different source-recovery strategies. Records: [environment study](../assets/templates/environment-study.yaml), [VM study](../assets/templates/virtual-machine-study.yaml). Unknown instructions follow the [custom VM procedure](virtual-machines.md).

## Lua, LuaJIT, and Luau

| Effort | Role | Qualification |
| --- | --- | --- |
| [unluac](https://sourceforge.net/projects/unluac/), [LuaDec](https://github.com/viruscamp/luadec) | Supported standard Lua chunk decompilation | Match chunk format, numeric representation and debug availability. LuaDec describes some later-version support as experimental. |
| [LJD / LuaJIT decompiler](https://github.com/Dr-MTN/luajit-decompiler) | LuaJIT bytecode reconstruction | Research/prototype lineage with explicit upstream correctness caveats. Pin the fork and opcode revision. |
| [Unluau](https://github.com/atrexus/unluau) | Luau source-like reconstruction | Upstream describes alpha/beta development and incomplete reliability. Probe complex constructs on the installed revision. |
| Matching `luac`, LuaJIT or Luau tooling | Independent bytecode/constant/prototype inspection | A compatible listing is the fallback when decompilation fails. These formats are not interchangeable. |

Identify header/version, endianness where applicable, integer/number widths, constants, prototypes, upvalues and stripped debug data. Preserve register lifetimes, open versus closed upvalues, multivalue returns, varargs, loop effects and error/coroutine boundaries. A reconstructed local scope may only be a readability choice.

Decompile one nested prototype, compare it to opcode/register effects, then run a controlled case on the matching interpreter when behavior matters. Separately track C API/FFI and native/JIT calls. Recompilation can change instruction layout without changing the selected behavior.

The [Lua fixture](../assets/fixtures/environment-patterns.lua) exercises a closure and protected call. [Profiles](environment-fixtures.md) cover source and standard-Lua bytecode. The [Lua bytecode header fixture](../assets/fixtures/lua-bytecode-header.yaml) gives a known Lua 5.4 `luac` header with the `LUAC_INT`/`LUAC_NUM` and endianness/size check-words as the checkable answer, including a reversed-`LUAC_INT` rejection case (see [format fixtures](format-fixtures.md)). LuaJIT/Luau require separately generated inputs; a standard-Lua pass does not certify either engine. Add coroutine yield/resume, varargs and shared-upvalue cases for relevant targets.

## Erlang and Elixir / BEAM

[OTP `beam_lib`](https://www.erlang.org/doc/apps/stdlib/beam_lib.html) exposes chunks and available abstract/debug forms; compatible `beam_disasm` and abstract-form formatting provide additional views. Record OTP version, module/function/arity, imports/exports, atoms, literals, code identity and debug backend.

Use retained abstract forms when available and label their origin. Debug backends are executable modules: only invoke a compatible trusted backend in the analysis runtime. Missing/encrypted debug information stays unavailable. BEAM disassembly is the fallback; reconstructed Erlang syntax does not imply original Elixir macros or source. The [BEAM container fixture](../assets/fixtures/beam-chunks.yaml) checks the `FOR1`/`BEAM` IFF structure, big-endian chunk sizes, 4-byte chunk padding, and the `AtU8` atoms, and encodes the hedge that chunk presence does not establish retained abstract forms (see [format fixtures](format-fixtures.md)).

Trace guards, pattern clauses, selective receive, message ordering, exceptions, tail calls, NIFs and ports. Separate available code versions during hot loading. A NIF body requires native analysis, and a message send does not establish which receive consumed it.

The [Erlang fixture](../assets/fixtures/environment_patterns.erl) exercises clauses, guards and an error result. Compare builds with and without debug forms using the [profiles](environment-fixtures.md). Add one selective receive with timeout and an Elixir-generated module to assess those representations explicitly.

## Ruby and PHP

| Environment | Candidate interface | Recovery boundary |
| --- | --- | --- |
| Ruby/MRI | [`RubyVM::InstructionSequence`](https://docs.ruby-lang.org/en/master/RubyVM/InstructionSequence.html) disassembly and matching native/runtime tools | VM-specific instructions and available source locations; serialized instruction forms are version-dependent and loading them is not generic safe deserialization. |
| PHP/Zend | [VLD](https://github.com/derickr/vld), matching [OPcache](https://www.php.net/manual/en/book.opcache.php) inspection | Opcode/control-flow inspection where supported; VLD is a disassembler, and OPcache is not a universal offline source decompiler. |

First separate shipped source from cached/serialized VM data and native extensions. Bind exact interpreter/build, configuration and extensions. For source compilation/disassembly, disable target-specific initialization where supported and record remaining effects; importing an application to inspect it can execute its startup.

In Ruby, track blocks, nonlocal returns, keyword arguments, refinements and dynamically replaced methods. In PHP, track references, variable-variable access, includes/autoloading, generators, exceptions and native extension calls. String tables cannot establish a complete source reconstruction. Encoded/protected formats need a compatible decoder or remain an explicit gap.

Representative cases include a captured variable, exceptional cleanup, dynamic method/include resolution and one native boundary. Bind the interpreter's trace or instruction evidence to each result and compare only the same runtime/configuration.

**Deliverable:** recovered abstract/source-like forms when supported, exact VM coordinates, checked control/data flow and unresolved dynamic/native behavior. Record the engine's maturity and failed constructs alongside successful output.
