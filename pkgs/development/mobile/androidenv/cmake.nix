{
  lib,
  stdenv,
  arch,
  autoPatchelfHook,
  deployAndroidPackage,
  meta,
  os,
  package,
  pkgs,
}:

deployAndroidPackage {
  inherit package os arch;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals (os == "linux") [
    pkgs.stdenv.cc.libc
    pkgs.stdenv.cc.cc
    pkgs.ncurses5
  ];

  patchInstructions = lib.optionalString (os == "linux") ''
    autoPatchelf $packageBaseDir/bin
  '';

  meta = meta // {
    license = lib.licenses.bsd3;
  };
}
