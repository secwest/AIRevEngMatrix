# Platform tracing, kernels, and specialized instruction sets

These workflows connect native code to operating-system and accelerator behavior. Template: [platform trace](../assets/templates/platform-trace.yaml). Captures and dumps also follow [runtime artifact](matching-and-runtime-artifacts.md) identity rules.

## Tool selection

| Family | Candidate tools | Result and dependency |
| --- | --- | --- |
| Linux process behavior | strace, ltrace, perf | System/library calls or sampled execution, tied to exact process/module identities; instrumentation scope differs among tools. |
| Linux dynamic tracing | [bpftrace](https://bpftrace.org/docs/) | Selected kernel/user events and arguments; available probes, permissions, BTF/debug data and ABI determine interpretation. |
| Linux kernel state | [drgn](https://drgn.readthedocs.io/en/latest/), crash, GDB | Typed live/dump state where supported; exact kernel build, modules, debug data and dump completeness matter. |
| Windows events and effects | ETW, WPR/WPA, [Process Monitor](https://learn.microsoft.com/en-us/sysinternals/downloads/procmon) | Selected events, file/registry/process effects and stacks; provider configuration, symbols and lost events constrain coverage. |
| Windows native and kernel debugging | WinDbg; x64dbg for supported user-mode targets | Registers, memory, breakpoints and exception state; kernel and process debugging are distinct configurations. |
| macOS and supported Unix tracing | LLDB, Instruments, DTrace where supported | Selected process/system observations; platform protections and probe availability can leave gaps. |
| eBPF | [bpftool](https://github.com/libbpf/bpftool), LLVM tools | Object, translated/JIT instructions, BTF, maps and attachment information where accessible. |
| CUDA GPU code | NVIDIA [cuobjdump and nvdisasm](https://docs.nvidia.com/cuda/cuda-binary-utilities/index.html) | PTX/SASS and binary metadata as supported; GPU generation, code object and driver context must match. |
| SPIR-V shaders/kernels | [SPIRV-Tools](https://github.com/KhronosGroup/SPIRV-Tools) | Validation, disassembly and transformations of compatible SPIR-V; target environment, extensions and bindings matter. |

Tool names identify candidate interfaces. A successful tool launch does not establish the required probe, privilege, architecture or artifact support.

## Bounded platform trace

1. Select the question and the smallest event set that can answer it. Bind process start identity, executable digest/build ID, child-process policy and capture window. A PID reused later is a new target.
2. Record provider/probe names, arguments, filters, buffers, sampling settings, clock source, symbol paths and versions. Distinguish entry events, return events, sampled stacks and complete instruction traces.
3. Capture a known event as a positive control. Check attach latency, dropped events, truncation, inaccessible modules and permission failures. Filters that remove evidence remain part of the result.
4. Join code locations to the correct module/load map at that time. Argument decoding uses the actual ABI and probe context; a register-sized value is not automatically a pointer or complete aggregate.
5. Repeat the scenario when relevant and compare declared observations. Record performance/timing perturbation and cleanup of owned tracing sessions.

**Deliverable:** raw trace, capture configuration, event explanation with process/thread/module identity, positive-control result and coverage gaps. A sampled absence cannot establish that a function never ran. File or registry operations can be attempted, failed or completed; preserve return status.

## Kernel and driver analysis

Acquire the exact kernel/module or driver and available matching symbols. Identify entry/registration callbacks, dispatch tables, system-call or device-control boundaries, interrupt/deferred-work paths and unload/cleanup behavior. Interpret structures using build-matched types and object lifetimes.

For dumps, retain physical/virtual address layers and omitted pages. For live state, record that concurrent mutation can invalidate a multi-read structure traversal. Use consistency checks on lists, bounds and object references; partial or corrupt structures stay partial. Kernel logging, tracing, attaching and loading a diagnostic module have different effects and permissions.

Trace one requested operation from userspace request through its kernel dispatch and back to the observable result. Preserve buffer direction, length checks, copy semantics, privilege checks, and asynchronous completion. A reachable registration entry does not establish that the requested device/configuration uses it.

## eBPF

Distinguish the input ELF/BTF object, the verifier-accepted translated program, and JIT native bytes. Record kernel version, program type, attachment, maps, BTF/CO-RE relocations, helper calls and available program identifiers. The same source/object can load differently across kernels.

Use bpftool/LLVM read or dump operations appropriate to the available artifact. Loading or attaching a program changes kernel state and is a separate step. Inspect branch and map access semantics in the relevant instruction form. JIT addresses and map contents are runtime observations, not permanent file coordinates. Verifier acceptance establishes verifier constraints for that load, not general correctness. The [eBPF object fixture](../assets/fixtures/ebpf-object.yaml) checks the `EM_BPF` ELF identity, the program section, and the decoded instructions as a static artifact, encoding the distinction between the ELF object and the in-kernel translated or JITed program (see [format fixtures](format-fixtures.md)).

## GPU and shader analysis

Identify the container and selected device code object. CUDA packages may contain both PTX and architecture-specific native code; PTX is an intermediate representation. SPIR-V validation requires an explicit target environment and extension set. Other GPU formats use the vendor's matching ISA/toolchain or remain unsupported.

Bind kernel entry points, argument layout, descriptor bindings, address spaces, shared/local memory, synchronization and host dispatch. Check thread/workgroup dimensions and numeric behavior, including widths and floating-point settings. An instruction listing alone does not establish the host-provided buffer contents or scheduling.

For a behavioral claim, compare a bounded known input on the matching runtime/device, retaining host and device artifacts. **Deliverable:** selected kernel/shader interpretation, code/IR locations, binding and execution conditions, and the observed scope. Original CUDA/GLSL/HLSL source is not implied by disassembly or IR output.
