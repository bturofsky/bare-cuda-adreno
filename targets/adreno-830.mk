# Adreno 830 — Snapdragon 8 Elite, the primary flagship target.
TARGET_NAME      = adreno-830
TARGET_GPU       = Adreno 830 (Snapdragon 8 Elite)
TARGET_ARCH      = Adreno (image processing architecture, sliced GPU)
TARGET_SPIRV_ENV = spv1.5
TARGET_SPIRV_MAX = 1.5
TARGET_DRIVER    = Qualcomm OpenCL / Vulkan driver stack (2024+)
TARGET_COMPUTE   = fp32 native; NO native fp64 (out of profile — honest limit); tile-based deferred rendering, local memory friendly
TARGET_MULTI_GPU = single GPU; heterogeneous SoC (CPU+GPU+NPU) lane later
TARGET_ROLE      = primary — the flagship mobile story
