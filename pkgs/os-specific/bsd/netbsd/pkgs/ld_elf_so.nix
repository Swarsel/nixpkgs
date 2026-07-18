{
  lib,
  defaultMakeFlags,
  libcMinimal,
  mkDerivation,
}:

mkDerivation {
  makeFlags = defaultMakeFlags ++ [
    "BINDIR=$(out)/libexec"
    "CLIBOBJ=${libcMinimal}/lib"
  ];

  LIBC_PIC = "${libcMinimal}/lib/libc_pic.a";
  # Hack to prevent a symlink being installed here for compatibility.
  SHLINKINSTALLDIR = "/usr/libexec";
  USE_FORT = "yes";

  extraPaths = [
    libcMinimal.path
    "sys"
  ];

  noLibc = true;
  path = "libexec/ld.elf_so";
  meta.platforms = lib.platforms.netbsd;
}
