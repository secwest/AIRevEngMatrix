# Python development and packaging environments

Scope: CPython bytecode, source-bearing packages, embedded interpreters, PyInstaller-style carriers and native extensions/AOT output. Records: [environment study](../assets/templates/environment-study.yaml), [VM study](../assets/templates/virtual-machine-study.yaml).

## Engines and supporting efforts

| Component | Role | Qualification |
| --- | --- | --- |
| [PyLingual](https://github.com/syssec-utd/pylingual) | Modern CPython bytecode-to-source reconstruction | Upstream describes broad version coverage and a local pipeline with target-version compilation checks. Pin code, model/configuration and target support; its local and hosted implementations can differ. |
| [pycdc](https://github.com/zrax/pycdc) | Bytecode disassembly and decompilation | Support for a version header does not establish support for every opcode or control-flow construct. |
| [uncompyle6](https://github.com/rocky/python-uncompyle6), [decompyle3](https://github.com/rocky/python-decompile3) | Reconstruction for their supported bytecode ranges | Select by the target bytecode version; the Python version that runs the tool is a separate requirement. |
| [xdis](https://github.com/rocky/python-xdis) | Version-qualified bytecode/code-object inspection | Supplies instruction evidence even where source reconstruction is unavailable. |
| [pyinstxtractor-ng](https://github.com/pyinstxtractor/pyinstxtractor-ng) | Supported PyInstaller extraction | Extraction and header repair have provenance; successful extraction does not prove complete decompilation. |

## Identify what was shipped

Record carrier, interpreter implementation/version, magic/header fields, optimization flags, nested code objects, native extensions and resource members. Check module identity before assigning source paths. PyPy, CPython, Nuitka/Cython-generated native code and a PyInstaller archive require different routes. A package suffix does not identify the executable representation.

Use a local engine for local artifact analysis. A hosted decompiler is a separate data-transfer choice; selecting its project name does not imply uploading the target. Pin any model/data dependencies and record whether setup needs additional interpreters or downloads.

## Reconstruct and verify

1. Extract a bounded carrier without executing its entry point. Retain original/repaired headers and every member digest.
2. Decode one representative code object with exact version semantics. Preserve constants, names, free/cell variables, nested objects, instruction offsets and exception regions.
3. Select a compatible source engine and preserve partial output, diagnostics and unsupported instructions. A plausible `def` body can still omit exceptional or generator paths.
4. Check closure capture, comprehensions, generators, async iteration/context managers, pattern matching and exception/finally handling against bytecode. Adaptive caches and opcode changes require the matching decoder.
5. For supported reconstructed source, compile under the target Python version and compare meaningful control/exception structure. A compiler round trip can tolerate renamed locals or different harmless layout while retaining semantics.
6. Run finite behavior cases in a bounded environment when required. Importing modules, resolving custom import hooks or unpickling data can execute code; these are runtime operations.

Native extensions and compiled Python implementations route to native analysis with the correct Python C/API/runtime boundary. Strings and Python-looking runtime helpers in a native binary do not supply missing code objects.

## Representative assessment

The [Python fixture](../assets/fixtures/environment_patterns.py) contains a closure and exception handling. [Profiles](environment-fixtures.md) create ordinary and optimized `.pyc` artifacts using the recorded interpreter. Compare source behavior separately from the decompiler's reconstruction; a new Python release may run the fixture while remaining unsupported by a selected decompiler.

Add nested generators, `finally` cleanup and an async cancellation case when those constructs drive the target question. An import-only smoke test is insufficient because it may never execute the reconstructed method.

**Deliverable:** recovered supported source, code-object/instruction mappings, bytecode/version evidence, checked cases and explicit unprocessed modules or native boundaries.
