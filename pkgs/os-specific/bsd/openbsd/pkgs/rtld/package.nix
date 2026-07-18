{
  lib,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./ldso-fix-makefile.patch
  ];

  # -fret-clean requires OpenBSD-specific patches to the compiler.
  postPatch = ''
    find . -type f -exec sed -i 's/-fret-clean//g' {} \;
  '';

  makeFlags = [ "STACK_PROTECTOR=1" ];

  # DESTDIR is overridden in bsdSetupHook, just fixup afterwards
  postInstall = ''
    mv $out/bin $out/libexec
  '';

  NIX_CFLAGS_COMPILE = "-Wno-error";

  extraPaths = [
    "lib/libc/string"
    "lib/csu/os-note-elf.h"
  ];

  libcMinimal = true;
  path = "libexec/ld.so";
  meta.platforms = lib.platforms.openbsd;
}
