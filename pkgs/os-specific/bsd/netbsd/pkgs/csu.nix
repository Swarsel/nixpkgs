{
  lib,
  bsdSetupHook,
  byacc,
  flex,
  genassym,
  gencat,
  groff,
  headers,
  install,
  ld_elf_so,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  netbsdSetupHook,
  statHook,
  sys-headers,
  tsort,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    mandoc
    groff
    flex
    byacc
    genassym
    gencat
    lorder
    tsort
    statHook
  ];

  buildInputs = [ headers ];

  extraPaths = [
    sys-headers.path
    ld_elf_so.path
  ];

  noLibc = true;
  path = "lib/csu";
  meta.platforms = lib.platforms.netbsd;
}
