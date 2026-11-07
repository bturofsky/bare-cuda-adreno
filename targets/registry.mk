# Bare CUDA Adreno — target pull-down registry.
#
# A "target" is one Qualcomm Adreno generation this project AOT-compiles
# CUDA kernels for, expressed as a SPIR-V profile with a per-target env
# version: the mobile driver stack's ceiling differs by SoC generation, so
# the pull-down changes what Khronos spirv-val accepts — a real, enforced
# per-target distinction. Adding a GPU is one file + one line in TARGETS.
#
#   make targets          list the pull-down
#   make select           interactive pull-down (persists .target)
#   make TARGET=adreno-830 aot    override for one invocation
#   TARGET unset          the persisted .target choice (default: adreno-830)

TARGETS = adreno-830 adreno-750 adreno-740

# The primary flagship target: Adreno 830 (Snapdragon 8 Elite).
DEFAULT_TARGET = adreno-830
