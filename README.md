# Bare CUDA Adreno

**CUDA kernels compiled ahead-of-time to per-target validated SPIR-V — the
IR Qualcomm's OpenCL/Vulkan driver stack consumes on Adreno (Snapdragon) —
with a target pull-down that changes what the Khronos validator actually
enforces per SoC generation. No runtime interception, no source rewrite.**

Fourth sibling in the **Bare CUDA** family: Metal (Apple, bitwise-verified
vs RTX 8000), ROCm (AMD MI210/W7800/W7900 via LLVM AMDGPU), Arc (Intel via
SPIR-V). Same discipline: translate once, compile **AOT**, validate at the
byte level, hard-fail loudly on anything unsupported.

```
+-----------------------------------------------------------------------------------+
|                     CUDA binary (real nvcc 12.4 fatbin)                           |
+-----------------------------------------------------------------------------------+
                                   |
                                   v  [ portability scanner ]
              fatbin container walk -> PTX extract (LZ4 / zstd / deflate)
                                   -> opcode census -> per-target SPIR-V feasibility
                                   |
                                   v  [ translator ]
                 PTX subset -> LLVM IR (spir64-unknown-unknown, OpenCL kernel)
                                   |
                                   v  [ LLVM AOT pipeline, per-target ]
              opt -O2 -> llvm-spirv --spirv-max-version <per-target>
                                   |
                                   v
        SPIR-V binaries that differ per SoC generation:
          adreno-830 -> SPIR-V 1.5 binary (spirv-val --target-env spv1.5)
          adreno-750 -> SPIR-V 1.3 binary (spirv-val --target-env spv1.3)
          adreno-740 -> SPIR-V 1.3 binary (spirv-val --target-env spv1.3)
                                   |
                                   v
        [ hardware gate: on-device launch via adb (phase 2) ]
```

## Verified today (v0, all measured — see [VERIFIED.md](VERIFIED.md))

| Gate | Proves | Result |
|---|---|---|
| Scanner | real nvcc 12.4 fatbin → census | 22/22 opcode hits — **FULLY PORTABLE v0** |
| Translator | PTX → LLVM IR | IR passes `opt` verification |
| SPIR-V lane | per-target binary versions | 830: v1.5 binary clean at `spv1.5`; 750/740: **v1.3 binaries** clean at `spv1.3` — the pull-down produces genuinely different artifacts |
| Honesty | unsupported opcode | **exit 2, opcode named** |
| Harness | 28 structured checks | **28/28 green**, `-Wall -Wextra -Werror` clean |

## Target pull-down

| Target | SoC | SPIR-V binary | env validated |
|---|---|---|---|
| `adreno-830` | Snapdragon 8 Elite | v1.5 | `spv1.5` |
| `adreno-750` | Snapdragon 8 Gen 3 | v1.3 | `spv1.3` |
| `adreno-740` | Snapdragon 8 Gen 2 | v1.3 | `spv1.3` |

Honest profile note recorded per target: Adreno has **no native fp64** —
fp64 kernels are out of profile (the family fixture is fp32; the scanner's
feasibility profile is where that boundary is enforced).

```bash
make targets          # list the pull-down
make select           # interactive picker (persists .target)
make aot              # build + validate for the selected target
make aot-all          # build for every registered target
make test             # the 28-check acceptance harness
make doctor           # toolchain audit
```

## Design rules (family standard)

1. **Translate once, compile AOT.** The `.spv` is a finished, validated
   artifact per target profile; the on-device driver compiles it to Adreno
   ISA at load. No runtime CUDA translation anywhere.
2. **Honesty contract.** Unsupported opcode → exit 2, opcode named.
3. **blockDim travels as data.** `_ntid_x` as an explicit kernel argument —
   the family calling convention shared across all four siblings.
4. **Validator-gated artifacts**, with a per-target twist unique to this
   repo: the SPIR-V binary version itself is part of the contract
   (`--spirv-max-version`), so older SoC profiles get strictly older-env
   validation — an artifact that passes spv1.3 also documents why it must.

## What's next

- **Phase 2 (hardware gate):** push the `.spv` over adb, load + launch on
  the device's OpenCL/Vulkan stack, pull results, element-verify — the
  suite skeleton (`scripts/verify_adreno.sh`) already detects the device.
- **Phase 3:** tile-memory census, heterogeneous CPU+GPU lane, subgroup
  shuffles, scanner-ordered census growth.

See [ARCHITECTURE.md](ARCHITECTURE.md) and [ROADMAP.md](ROADMAP.md).

## Family

| Project | Target | Status |
|---|---|---|
| [Bare CUDA Metal](https://github.com/bturofsky/bare-cuda-metal) | Apple M1–M5 via Metal, AOT `.metallib` | bitwise-verified vs RTX 8000 |
| [Bare CUDA ROCm](https://github.com/bturofsky/bare-cuda-rocm) | AMD MI210 / W7800 / W7900 via LLVM AMDGPU | v0: native AMDGCN code objects |
| [Bare CUDA Arc](https://github.com/bturofsky/bare-cuda-arc) | Intel Arc A770 / B580 / Flex 170 via SPIR-V | v0: validated SPIR-V lane |
| **Bare CUDA Adreno** (this repo) | Qualcomm Adreno 830 / 750 / 740 via SPIR-V | v0: per-target-version validated SPIR-V lane |

## Credits & license

MIT — original work. NVIDIA, AMD, Intel and Qualcomm own their respective
trademarks; this is an independent interoperability project, unaffiliated
with any of them, shipping none of their SDK code.
