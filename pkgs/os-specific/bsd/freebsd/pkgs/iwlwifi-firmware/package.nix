{
  lib,
  buildFreebsd,
  linux-firmware,
  mkDerivation,
  sys,
}:
mkDerivation rec {
  pname = "iwlwifi-firmware";
  version = linux-firmware.version;
  # Upstream FreeBSD doesn't wrap wifi firmware, only gpu firmware.
  # We have to write our own build scripts for this.
  src = ./src;

  outputs = [
    "out"
    "debug"
  ];

  makeFlags = [
    "DEBUG_FLAGS=-g"
    "XARGS_J=xargs-j"
    "NO_XREF=1"
  ];

  env = sys.passthru.env;

  preConfigure = ''
    bash gen-makefiles
  '';

  KERN_DEBUGDIR = "${builtins.placeholder "debug"}/lib/debug";
  KERN_DEBUGDIR_KMODDIR = "${KERN_DEBUGDIR}/kernel";
  KERN_DEBUGDIR_KODIR = "${KERN_DEBUGDIR}/kernel";
  KMODDIR = "${placeholder "out"}/kernel";
  LINUX_FIRMWARE = "${linux-firmware}/lib/firmware";
  SYSDIR = "${sys.src}/sys";
  extraNativeBuildInputs = [ buildFreebsd.xargs-j ];

  # generates relocations the linker can't handle
  hardeningDisable = [
    "pic"
  ];

  # out-of-tree, but we still want to use freebsd.mkDerivation, which wants an in-tree path
  path = "...";

  meta = {
    description = "Intel Wifi Firmware for FreeBSD";
    license = linux-firmware.meta.license;
    platforms = lib.platforms.freebsd;
  };
}
