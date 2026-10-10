# C and C++ development environments

Scope: MSVC/Visual Studio, GCC, Clang/LLVM, MinGW, and compatible embedded toolchains. Bind the actual target ABI and runtime; an IDE name does not identify either. Shared records: [environment study](../assets/templates/environment-study.yaml) and [decompilation study](../assets/templates/decompilation-study.yaml).

## Engines and supporting efforts

| Component | Use | Qualification |
| --- | --- | --- |
| Ghidra, Hex-Rays, Binary Ninja | Native decompilation, types, references and intermediate representations | Select the processor, compiler specification, installed decompiler and edition from the [engine taxonomy](language-decompilation.md). |
| radare2/r2ghidra, Rizin/rz-ghidra | Scriptable native analysis with Ghidra-derived decompilation | Host/plugin versions are paired; common decompiler ancestry reduces independence between results. |
| LLVM/GNU binary tools, `dumpbin`, PDB/DWARF readers | Symbols, relocations, unwind data and raw instruction checks | Match debug identities; demangling recovers names without proving object layout. |
| RetDec | Alternative native reconstruction for supported inputs | Limited maintenance is documented in the engine taxonomy; use a representative fixture before selecting it. |

## Intake and recovery

1. Identify PE/ELF/Mach-O or raw firmware, architecture, endianness, calling convention, CRT/STL identity, exception model and available debug data. Separate MSVC ABI from Itanium-family implementations; MinGW is not synonymous with MSVC. The [Itanium C++ ABI](https://itanium-cxx-abi.github.io/cxx-abi/abi.html) is a layout/reference source only for applicable targets.
2. Map executable ranges, relocations, imports and unwind records before selecting functions. Recover library identities conservatively: templates, statically linked runtimes, LTO and identical-code folding can merge application and library boundaries.
3. Decompile the selected entry and callers. Correct argument/return locations and hidden parameters before interpreting objects or propagating types. Preserve pre-correction output so a type guess cannot silently become evidence.
4. Recover object relationships from allocation size, constructors, vptr writes, member accesses, dispatch and destruction. Record candidate subobject offsets and ownership transitions with their call sites.
5. Check normal, early-return and exceptional paths against instructions and unwind/landing-pad records. A decompiler can omit cleanup or misrepresent exception edges while producing readable code.

## Constructs that change the analysis

| Construct | Required interpretation and check |
| --- | --- |
| Multiple/virtual inheritance | Distinguish complete objects, subobjects, adjustment thunks and construction vtables. Validate `this` adjustments at each call. |
| Templates and lambdas | Identify concrete instantiations and captured state. Inlining can erase the generic definition and closure boundary. |
| RAII, exceptions and SEH | Track resource acquisition, each release and exceptional cleanup under the actual compiler exception model. |
| STL containers and strings | Match implementation/version/debug mode before importing layouts; small-string optimization and iterator checks vary. |
| Atomics and concurrency | Preserve widths, orderings where evidenced and synchronization calls. One observed schedule does not establish all interleavings. |
| C interfaces, varargs and packed records | Check promotions, alignment, signedness and length contracts. A plausible prototype may still decode arguments incorrectly. |

## Representative assessment

The [C++ fixture](../assets/fixtures/environment-patterns.cpp) exercises virtual dispatch, a templated invocation, parsing and an exception path. Build both debug and optimized variants using the [fixture profiles](environment-fixtures.md). MSVC and GCC/Clang builds are separate assessments, even on the same CPU.

For the target's relevant features, add fixtures for multiple inheritance, destructor execution after a throw, aggregate return and packed FFI data. Check behavior and decisive instruction paths; do not require retained vtables or calls when optimization has legitimately removed them.

**Deliverable:** function/object explanation, pseudocode and its engine identity, checked ABI and exception paths, original locations, and unresolved compiler assumptions. Headers, comments, macros and the original class design may remain unrecoverable.
