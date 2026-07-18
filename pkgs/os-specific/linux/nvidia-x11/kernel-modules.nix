{
  lib,
  stdenv,
  fetchFromGitHub,
  broken,
  kernel,
  kernelModuleMakeFlags,
  nvidia_x11,
  open,
  patches,
  hash ? null,
}:

assert open -> hash != null;

stdenv.mkDerivation {
  inherit patches;
  pname = "nvidia-${if open then "open" else "kernel-modules"}";
  version = "${nvidia_x11.version}-${kernel.version}";

  src =
    if open then
      fetchFromGitHub {
        inherit hash;
        owner = "NVIDIA";
        repo = "open-gpu-kernel-modules";
        tag = nvidia_x11.version;
      }
    else
      nvidia_x11.modsrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags =
    kernelModuleMakeFlags
    ++ [
      "IGNORE_PREEMPT_RT_PRESENCE=1"
      "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
      "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "MODLIB=$(out)/lib/modules/${kernel.modDirVersion}"
      "DATE="
      "TARGET_ARCH=${stdenv.hostPlatform.parsed.cpu.name}"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "C_INCLUDE_PATH=${lib.getLib stdenv.cc.cc}/lib/clang/${lib.versions.major stdenv.cc.cc.version}/include"
    ];

  allowedReferences = [ ];
  buildTargets = [ "modules" ];
  enableParallelBuilding = true;
  installTargets = [ "modules_install" ];

  meta = {
    inherit broken;
    description = "NVIDIA Linux ${lib.optionalString open "Open "}GPU Kernel Modules";

    homepage =
      if open then "https://github.com/NVIDIA/open-gpu-kernel-modules" else nvidia_x11.meta.homepage;

    license =
      if open then
        with lib.licenses;
        [
          gpl2Plus
          mit
        ]
      else
        nvidia_x11.meta.license;

    sourceProvenance =
      with lib.sourceTypes;
      [
        fromSource
      ]
      ++ lib.optional (!open) binaryNativeCode;

    maintainers = with lib.maintainers; [ nickcao ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
