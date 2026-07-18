{
  lib,
  bsdSetupHook,
  fetchpatch,
  include,
  install,
  makeMinimal,
  mkDerivation,
  openbsdSetupHook,
}:

mkDerivation {
  patches = [
    # Support for a new NOBLIBSTATIC make variable
    (fetchpatch {
      hash = "sha256-ZMegMq/A/SeFp8fofIyF0AA0IUo/11ZgKxg/UNT4z3E=";
      includes = [ "libexec/ld.so/*" ];
      name = "nolibstatic-support.patch";
      url = "https://marc.info/?l=openbsd-tech&m=171972639411562&q=raw";
    })
  ];

  nativeBuildInputs = [
    bsdSetupHook
    openbsdSetupHook
    makeMinimal
    install
  ];

  buildInputs = [ include ];
  extraPaths = [ "libexec/ld.so" ];
  noLibc = true;
  path = "lib/csu";
  meta.platforms = lib.platforms.openbsd;
}
