# Adreno 750 — Snapdragon 8 Gen 3, second target.
TARGET_NAME      = adreno-750
TARGET_GPU       = Adreno 750 (Snapdragon 8 Gen 3)
TARGET_ARCH      = Adreno
TARGET_SPIRV_ENV = spv1.3
TARGET_SPIRV_MAX = 1.3
TARGET_DRIVER    = Qualcomm OpenCL / Vulkan driver stack (2023)
TARGET_COMPUTE   = fp32 native; NO native fp64; 16-wide sub-kernels per shader processor pair
TARGET_MULTI_GPU = single GPU
TARGET_ROLE      = secondary — the installed-base proof (strict spv1.3 validation)
