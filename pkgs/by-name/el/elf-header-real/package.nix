{
  lib,
  glibc,
  musl,
  stdenvNoCC,
}:

let
  libc = if stdenvNoCC.targetPlatform.isMusl then musl else glibc;
  headerPath =
    if stdenvNoCC.targetPlatform.isMusl then
      "musl-${libc.version}/include/elf.h"
    else
      "glibc-${libc.version}/elf/elf.h";
in

stdenvNoCC.mkDerivation {
  inherit (libc) version;
  pname = "elf-header";
  src = null;

  installPhase = ''
    mkdir -p "$out/include";
    tar -xf \
        ${lib.escapeShellArg libc.src} \
        ${lib.escapeShellArg headerPath} \
        --to-stdout \
      | sed -e '/features\.h/d' \
      > "$out/include/elf.h"
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = libc.meta // {
    description = "Datastructures of ELF according to the target platform's libc";

    longDescription = ''
      The Executable and Linkable Format (ELF, formerly named Extensible Linking
      Format), is usually defined in a header like this.
    '';

    maintainers = [ lib.maintainers.ericson2314 ];
    platforms = lib.platforms.all;
    outputsToInstall = [ "out" ];
  };
}
