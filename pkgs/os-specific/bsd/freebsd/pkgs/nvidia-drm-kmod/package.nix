{
  lib,
  stdenv,
  fetchurl,
  drm-kmod,
  fetchpatch,
  mkDerivation,
  nvidia-driver,
  sys,
  xargs-j,
}:
mkDerivation rec {
  inherit (nvidia-driver) version src;
  pname = "nvidia-drm-kmod";

  outputs = [
    "out"
    "debug"
  ];

  patches =
    lib.optionals (lib.versionOlder version "565") [
      (fetchpatch {
        extraPrefix = "a/src/nvidia-drm";
        hash = "sha256-EgzEx1VxQyoNpnY0MnNVa08A0ENSyU/rdRM2hOwUE2g=";
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/d07cdab9108a8cf6ab66aa1ff834339f8695f457/graphics/nvidia-drm-61-kmod/files/extra-patch-nvidia-drm-conftest.h";
      })
    ]
    ++ lib.optionals (lib.versionOlder version "555") [
      (fetchpatch {
        extraPrefix = "a/src/nvidia-drm";
        hash = "sha256-aFOs811J5e9Nu8Kwd6dImiSefEOlKlnRp3kg7DTIccg=";
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/d07cdab9108a8cf6ab66aa1ff834339f8695f457/graphics/nvidia-drm-61-kmod/files/extra-patch-nvidia-drm-freebsd-lkpi.c";
      })
    ];

  postPatch =
    lib.optionalString (lib.versionAtLeast version "570") ''
      sed -E -i -e 's:\&nv_drm_fbdev_module_param\,  1\,:\&nv_drm_fbdev_module_param\,  0\,:' src/nvidia-drm/nvidia-drm-freebsd-lkpi.c
      sed -E -i -e 's:bool nv_drm_fbdev_module_param = true;:bool nv_drm_fbdev_module_param = false;:' src/nvidia-drm/nvidia-drm-os-interface.c
    ''
    + ''
      sed -E -i -e '/DRMKMODDIR.*\/linuxkpi\/dummy\/include/d' src/nvidia-drm/Makefile

      mkdir -p $TMP/bin
      ln -s ${stdenv.cc}/bin/${stdenv.cc.targetPrefix}nm $TMP/bin/nm
      export PATH=$PATH:$TMP/bin
    '';

  makeFlags = [
    "BSDSRCTOP=${sys.src}"
    "SYSDIR=${sys.src}/sys"
    "DRMKMODDIR=${drm-kmod.src}"
    "NO_XREF=1"
    "DEBUG_FLAGS=-g"
  ];

  env.CONFTEST_BSD_KMODPATHS = "${sys}/kernel ${drm-kmod}/kernel";
  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration"; # conftests rely on this

  preConfigure = ''
    cd src/nvidia-drm
  '';

  KERN_DEBUGDIR = "${builtins.placeholder "debug"}/lib/debug";
  KERN_DEBUGDIR_KMODDIR = "${KERN_DEBUGDIR}/kernel";
  KERN_DEBUGDIR_KODIR = "${KERN_DEBUGDIR}/kernel";
  KMODDIR = "${builtins.placeholder "out"}/kernel";

  extraNativeBuildInputs = [
    xargs-j
  ];

  hardeningDisable = [
    "pic" # generates relocations the linker can't handle
  ];

  path = "...";
  meta.license = lib.licenses.unfree;
  meta.platforms = [ "x86_64-freebsd" ];
}
