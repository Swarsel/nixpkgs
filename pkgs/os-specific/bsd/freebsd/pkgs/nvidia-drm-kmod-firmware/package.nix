{
  lib,
  kldxref,
  mkDerivation,
  nvidia-drm-kmod,
  sys,
  xargs-j,
}:
mkDerivation {
  inherit (nvidia-drm-kmod) version src;
  pname = "nvidia-drm-kmod-firmware";

  makeFlags = [
    "SYSDIR=${sys.src}/sys"
    "KMODDIR=${builtins.placeholder "out"}/kernel"
    "NO_XREF=1"
  ];

  preConfigure = ''
    cd firmware
  '';

  extraNativeBuildInputs = [
    xargs-j
    kldxref
  ];

  hardeningDisable = [
    "pic" # generates relocations the linker can't handle
  ];

  path = "...";
  meta.license = lib.licenses.unfreeRedistributableFirmware;
  meta.platforms = [ "x86_64-freebsd" ];
  meta.sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
}
