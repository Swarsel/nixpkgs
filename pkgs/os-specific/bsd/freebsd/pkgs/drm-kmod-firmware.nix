{
  lib,
  fetchFromGitHub,
  buildFreebsd,
  mkDerivation,
  sys,
  withAmd ? true,
  withIntel ? true,
}:
mkDerivation rec {
  pname =
    "drm-kmod-firmware" + lib.optionalString withAmd "-amd" + lib.optionalString withIntel "-intel";

  version = "20250109";

  src = fetchFromGitHub {
    owner = "freebsd";
    repo = "drm-kmod-firmware";
    rev = version;
    hash = "sha256-Z+hZpOogUI4GCZcRYElkO0oeCAG0WhBFh7kS3wuo43c=";
  };

  outputs = [
    "out"
    "debug"
  ];

  makeFlags = [
    "DEBUG_FLAGS=-g"
    "XARGS_J=xargs-j"
  ];

  env = sys.passthru.env;
  KERN_DEBUGDIR = "${builtins.placeholder "debug"}/lib/debug";
  KERN_DEBUGDIR_KMODDIR = "${KERN_DEBUGDIR}/kernel";
  KERN_DEBUGDIR_KODIR = "${KERN_DEBUGDIR}/kernel";
  KMODDIR = "${placeholder "out"}/kernel";

  KMODS =
    lib.optional withIntel "i915kmsfw"
    ++ lib.optionals withAmd [
      "amdgpukmsfw"
      "radeonkmsfw"
    ];

  # hardeningDisable = stackprotector doesn't seem to be enough, put it in cflags too
  NIX_CFLAGS_COMPILE = "-fno-stack-protector";
  SYSDIR = "${sys.src}/sys";
  extraNativeBuildInputs = [ buildFreebsd.xargs-j ];

  hardeningDisable = [
    "pic" # generates relocations the linker can't handle
    "stackprotector" # generates stack protection for the function generating the stack canary
  ];

  path = "...";

  meta = {
    description = "GPU firmware for FreeBSD drm-kmod";

    license =
      lib.optional withAmd lib.licenses.unfreeRedistributableFirmware
      # Intel license prohibits modification. this will wrap firmware files in an ELF
      ++ lib.optional withIntel lib.licenses.unfree;

    sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
    platforms = lib.platforms.freebsd;
  };
}
