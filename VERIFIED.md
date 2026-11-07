# Test Results — Bare CUDA Adreno v0

**Project:** Bare CUDA Adreno (repo `bare-cuda-adreno`) · **Date:** 2026-11-07 ·
**All measurements taken this session, live, on the build host.**

**Build host:** Apple M4 Mac mini, macOS 26.6 — LLVM 23.1.5 (`opt`),
SPIRV-LLVM-Translator 23.1.3, SPIRV-Tools 1.4.363.0. **No Adreno device was
attached** — by design: the v0 lane is hardware-free;
`scripts/verify_adreno.sh` arms on the device (adb / Turnip).

## 1. Scanner: real nvcc 12.4 fatbin → FULLY PORTABLE v0

```
fatbin containers: 1 · PTX: 1,034 bytes decoded · kernels: 1
distinct opcodes: 12 · hits: 22
feasibility vs target 'adreno-830': 22/22 hits in v0 profile — FULLY PORTABLE v0
```

The fixture is fp32 — deliberately, because **no Adreno generation has
native fp64**: the family fixture exercises the profile Adreno can actually
run, and the boundary is recorded in every target file.

## 2. Translator + optimizer

Fixture kernel translated (exit 0); IR passed `opt` verification; `opt -O2`
promoted all register slots; `spir_kernel` entry + `_ntid_x`
blockDim-as-data + `addrspace(1)` globals all present (the family calling
convention).

## 3. Per-target SPIR-V artifacts — the pull-down's real distinction

The SPIR-V **binary version** is part of the target contract
(`llvm-spirv --spirv-max-version`), so each target produces a genuinely
different artifact, strictly validated at its own env:

| Target | SoC | Binary version | `spirv-val --target-env` | Result |
|---|---|---|---|---|
| `adreno-830` | Snapdragon 8 Elite | SPIR-V 1.5 | `spv1.5` | clean — Kernel cap, entry, symbol, OpenCL.std, CrossWorkgroup |
| `adreno-750` | Snapdragon 8 Gen 3 | SPIR-V 1.3 | `spv1.3` | clean |
| `adreno-740` | Snapdragon 8 Gen 2 | SPIR-V 1.3 | `spv1.3` | clean |

This gate caught a real bug during development: the first artifacts were
emitted at binary version 1.4 and **failed spv1.3 validation** — exactly
the class of per-target mismatch this repo exists to catch. The fix
(`--spirv-max-version` per target) is now part of the enforced contract.

## 4. Honesty contract

`shfl.idx.b32` → exit 2, opcode named; unknown kernel → exit 1; validator
negative-tested (rejects junk).

## 5. Harness record

`make test` → **28/28 green**, builds `-Wall -Wextra -Werror` clean.
`make doctor` → PASS.

## 6. What is NOT verified yet (honest residual)

- **No kernel has executed on Adreno hardware yet** — v0 ends at validated
  SPIR-V; the on-device gate (`verify_adreno.sh`) arms via adb.
- The OpenCL/Vulkan driver path choice on-device (Qualcomm OpenCL vs Vulkan
  compute) is a phase-2 measurement, not an assumption.
- Profiled-not-lowered: `shfl`, `bar.sync`, `atom.add.u32`, `selp`.

**Reproduce:** `make doctor && make test`, `make aot-all`,
`scripts/verify_adreno.sh` (arms on the device).
