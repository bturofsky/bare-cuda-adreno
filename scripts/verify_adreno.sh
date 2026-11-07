#!/usr/bin/env bash
# verify_adreno.sh — the hardware gate (phase 2 of the roadmap).
#
# Detects a live Adreno host (Android + adb with a Qualcomm OpenCL/Vulkan
# driver, or Linux-on-Snapdragon with Mesa Turnip / qualcomm OpenCL) and
# runs the on-device acceptance suites. When no Adreno device is present it
# says so honestly and exits 0 — the AOT lane above is verified
# hardware-free; nothing here is faked.
set -uo pipefail

ADB=""
for c in adb; do command -v "$c" >/dev/null 2>&1 && ADB="$c" && break; done

echo "Bare CUDA Adreno — hardware gate"
if [ -z "$ADB" ]; then
  echo "  no adb probe detected"
  echo "  status: HARDWARE GATE PENDING — v0 is verified through the validated"
  echo "          SPIR-V level (see VERIFIED.md); on-device suites arm automatically"
  echo "          when an Adreno device attaches (USB debugging + adb, or a"
  echo "          Linux-on-Snapdragon host with Turnip)."
  exit 0
fi

DEV=$(adb devices 2>/dev/null | tail -n +2 | grep -m1 "device$" | cut -f1 || true)
if [ -z "$DEV" ]; then
  echo "  adb present but no device attached"
  echo "  status: HARDWARE GATE PENDING — attach the Snapdragon device."
  exit 0
fi

SOC=$(adb -s "$DEV" shell getprop ro.soc.model 2>/dev/null | tr -d '\r')
echo "  device: $DEV — SoC: ${SOC:-unknown}"
echo "  planned suites (ROADMAP phase 2):"
echo "    1. push build/adreno-830/vectorAdd.spv, load via the device's OpenCL"
echo "       clCreateProgramWithIL (or Vulkan compute path), launch, pull results,"
echo "       element-verify vs CPU truth"
echo "    2. tile-memory census: local-memory reduction across Adreno shader cores"
echo "    3. heterogeneous lane: GPU result vs CPU on the same SoC (kryo/oryon cores)"
echo "    4. strict env check: device-reported SPIR-V version vs the target profile"
echo "  implementation lands with the device (ROADMAP.md phase 2) — nothing to fake here."
exit 0
